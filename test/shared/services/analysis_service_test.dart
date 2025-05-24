import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_reader/shared/services/analysis_service.dart';
import 'package:research_reader/shared/services/gemini_service.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/core/errors/app_exceptions.dart';
import 'package:research_reader/shared/repositories/document_repository.dart'; // For MockDocumentRepository
import 'package:path_provider/path_provider.dart'; // For temp directory
import 'package:syncfusion_flutter_pdf/pdf.dart'; // For creating a dummy PDF

// Mocks
class MockGeminiService extends Mock implements GeminiService {}
class MockDocumentRepository extends Mock implements DocumentRepository {}

// Fallback values for any() matchers
class FakeDocument extends Fake implements Document {}

void main() {
  late AnalysisService analysisService;
  late MockGeminiService mockGeminiService;
  late MockDocumentRepository mockDocumentRepository;
  late Directory tempDir;
  late File dummyPdfFile;
  late File emptyPdfFile;
  late File corruptPdfFile; // For testing extraction failure path

  setUpAll(() {
    registerFallbackValue(FakeDocument());
  });

  setUp(() async {
    mockGeminiService = MockGeminiService();
    mockDocumentRepository = MockDocumentRepository();
    // Provide a default apiEndpoint, though not used by generateSummary directly
    analysisService = AnalysisService(mockDocumentRepository, mockGeminiService, apiEndpoint: 'dummy_endpoint');

    // Create a real temporary PDF file for testing _extractTextFromPdf implicitly
    tempDir = await getTemporaryDirectory();
    
    // Dummy PDF with actual content
    dummyPdfFile = File('${tempDir.path}/dummy.pdf');
    final PdfDocument document = PdfDocument();
    document.pages.add().graphics.drawString(
        'This is a test document content for summary.',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 0, 150, 20));
    await dummyPdfFile.writeAsBytes(await document.save());
    document.dispose();

    // Empty PDF (valid PDF, but no text)
    emptyPdfFile = File('${tempDir.path}/empty.pdf');
    final PdfDocument emptyDoc = PdfDocument();
    emptyDoc.pages.add(); // Add a blank page
    await emptyPdfFile.writeAsBytes(await emptyDoc.save());
    emptyDoc.dispose();
    
    // Corrupt/Non-PDF file to simulate extraction error for DocumentProcessingException
    corruptPdfFile = File('${tempDir.path}/corrupt.txt');
    await corruptPdfFile.writeAsString("This is not a PDF.");

    // Mock repository calls that might be triggered if analyzeDocument were part of this.
    // For generateSummary, it doesn't directly use the repository.
    when(() => mockDocumentRepository.saveDocument(any())).thenAnswer((_) async => Future.value());
  });

  tearDownAll(() async {
    // Clean up temporary directory and files
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('generateSummary', () {
    final testDocument = Document(
      id: '1',
      title: 'Test Doc',
      filePath: '', // Will be set per test case
      pageCount: 1,
      uploadDate: DateTime.now(),
    );

    const String extractedText = 'This is a test document content for summary.';
    const String generatedSummaryText = "Generated summary.";
    const String emptyDocMessage = "Document is empty or text could not be extracted. Summary cannot be generated.";

    test('successfully generates a summary', () async {
      final docWithContent = testDocument.copyWith(filePath: dummyPdfFile.path);

      when(() => mockGeminiService.generateTextAnalysis(
        text: any(named: 'text'), // We verify the actual text below if needed
        prompt: any(named: 'prompt'),
      )).thenAnswer((invocation) async {
        // Check if the text passed to Gemini is what we expect from the PDF
        expect(invocation.namedArguments[#text], contains(extractedText.substring(0,10))); // Check a part
        return generatedSummaryText;
      });

      final result = await analysisService.generateSummary(docWithContent);

      expect(result, generatedSummaryText);
      verify(() => mockGeminiService.generateTextAnalysis(
            text: any(named: 'text', that: contains(extractedText.substring(0,10))),
            prompt: any(named: 'prompt'),
          )).called(1);
    });

    test('throws AIAnalysisException when GeminiService fails', () async {
      final docWithContent = testDocument.copyWith(filePath: dummyPdfFile.path);
      final apiException = AIAnalysisException("API error");

      when(() => mockGeminiService.generateTextAnalysis(
        text: any(named: 'text'),
        prompt: any(named: 'prompt'),
      )).thenThrow(apiException);

      expect(
        () => analysisService.generateSummary(docWithContent),
        throwsA(isA<AIAnalysisException>()),
      );
    });

    test('returns specific message for empty document content (after extraction)', () async {
      final emptyContentDoc = testDocument.copyWith(filePath: emptyPdfFile.path);
      
      // _extractTextFromPdf will run and return an empty string for emptyPdfFile

      final result = await analysisService.generateSummary(emptyContentDoc);

      expect(result, emptyDocMessage);
      verifyNever(() => mockGeminiService.generateTextAnalysis(
            text: any(named: 'text'),
            prompt: any(named: 'prompt'),
          ));
    });

    test('throws AIAnalysisException when text extraction fails (DocumentProcessingException)', () async {
      // Use a file path that will cause _extractTextFromPdf to fail
      final docWithBadPath = testDocument.copyWith(filePath: corruptPdfFile.path); 
      // _extractTextFromPdf will throw DocumentProcessingException due to invalid PDF content

      expect(
        analysisService.generateSummary(docWithBadPath),
        throwsA(isA<AIAnalysisException>().having(
          (e) => e.message, 
          'message', 
          "Could not generate summary: Error processing document."
        ).having(
          (e) => e.details,
          'details',
          isA<DocumentProcessingException>()
        )),
      );
      verifyNever(() => mockGeminiService.generateTextAnalysis(
            text: any(named: 'text'),
            prompt: any(named: 'prompt'),
          ));
    });
    
    test('throws AIAnalysisException for other unexpected errors during summary generation', () async {
      final docWithContent = testDocument.copyWith(filePath: dummyPdfFile.path);
      final unexpectedException = Exception("Unexpected internal error");

      when(() => mockGeminiService.generateTextAnalysis(
        text: any(named: 'text'),
        prompt: any(named: 'prompt'),
      )).thenThrow(unexpectedException); // Simulate error after text extraction but within Gemini call path

      expect(
        () => analysisService.generateSummary(docWithContent),
        throwsA(isA<AIAnalysisException>().having(
            (e) => e.message,
            'message',
            "An unexpected error occurred while generating the summary."
        )),
      );
    });

  });
}
