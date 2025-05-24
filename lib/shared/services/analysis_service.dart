import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // Keep for _sendForAnalysis if it's still used elsewhere
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';
import '../../core/errors/app_exceptions.dart';
import './gemini_service.dart'; // Added import for GeminiService
import '../../core/utils/logger.dart'; // Added import for AppLogger

class AnalysisService {
  final DocumentRepository _repository;
  final GeminiService _geminiService; // Added GeminiService field
  final String _apiEndpoint; // This might become obsolete if all analysis goes via Gemini
  static const String _tag = "AnalysisService"; // Tag for AppLogger

  // Modified constructor to accept GeminiService
  AnalysisService(this._repository, this._geminiService, {String? apiEndpoint})
      : _apiEndpoint = apiEndpoint ?? 'https://api.researchreader.com/analyze'; // TODO: Re-evaluate _apiEndpoint necessity

  // The analyzeDocument method seems to use a different API endpoint (_apiEndpoint)
  // and a different request structure (_sendForAnalysis).
  // For this subtask, I will focus on implementing the specific TODO methods
  // (extractCitations, generateSummary, analyzeStatistics) using _geminiService.
  // The existing analyzeDocument and _sendForAnalysis might be for a different type of analysis
  // or an older implementation.

  Future<Document> analyzeDocument(Document document) async {
    // This method uses _sendForAnalysis which hits _apiEndpoint.
    // It's not using GeminiService directly for its main analysis object.
    // The subtask is to implement the TODOs using Gemini.
    // This method's refactoring to use Gemini for its "summary" field
    // would be a separate step if desired.
    try {
      final analyzingDoc = document.copyWith(status: DocumentStatus.analyzing);
      await _repository.saveDocument(analyzingDoc);

      final text = await _extractTextFromPdf(document.filePath);
      
      // If the goal is to get a summary from Gemini for this main analysis:
      // final summaryText = await generateSummary(document); // Call the new method
      // For now, keeping the old flow for analyzeDocument's summary:
      final analysis = await _sendForAnalysis(text); // Old flow
      
      final analyzedDoc = document.copyWith(
        status: DocumentStatus.analyzed,
        summary: analysis['summary'], // This summary comes from _apiEndpoint
        // Add other analysis fields here
      );
      
      await _repository.saveDocument(analyzedDoc);
      return analyzedDoc;
    } catch (e,s) {
      AppLogger.logError("Error in analyzeDocument for ${document.id}", error: e, stackTrace: s, tag: _tag);
      try {
        final errorDoc = document.copyWith(status: DocumentStatus.error);
        await _repository.saveDocument(errorDoc);
      } catch (saveError, sse) {
         AppLogger.logError("Failed to save error status for document ${document.id}", error: saveError, stackTrace: sse, tag: _tag);
      }
      if (e is AppException) rethrow;
      throw AIAnalysisException("An unexpected error occurred during document analysis.", details: e.toString());
    }
  }

  Future<String> _extractTextFromPdf(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final pdfDoc = PdfDocument(inputBytes: bytes); // Renamed to avoid conflict
      final text = <String>[];

      for (var i = 0; i < pdfDoc.pages.count; i++) {
        final extractor = PdfTextExtractor(pdfDoc);
        text.add(extractor.extractText(startPageIndex: i)); 
      }

      pdfDoc.dispose();
      return text.join('\n');
    } on FileSystemException catch (e,s) {
      AppLogger.logError("File system error extracting text from PDF: ${e.message}", error:e, stackTrace:s, tag: _tag);
      throw DocumentProcessingException("File system error extracting text from PDF: ${e.message}", details: e);
    } catch (e,s) {
      AppLogger.logError("Failed to extract text from PDF.", error:e, stackTrace:s, tag: _tag);
      if (e is AppException) rethrow;
      throw DocumentProcessingException("Failed to extract text from PDF.", details: e.toString());
    }
  }

  // This method seems to be for a different API/purpose than the Gemini-based analysis tasks.
  // It's kept for now as analyzeDocument uses it.
  Future<Map<String, dynamic>> _sendForAnalysis(String text) async {
    // ... (implementation as before, using _apiEndpoint and http.post)
    // For brevity, I'm not re-pasting the whole method, assuming it remains.
    // Ensure its error handling is also robust (it was improved in previous subtasks).
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'analysis_type': [
            'summary',
            'methodology',
            'statistics',
            'future_research',
            'citations'
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw AIAnalysisException(
          'Analysis API request failed (old endpoint). Status code: ${response.statusCode}', 
          code: response.statusCode.toString(),
          details: response.body,
        );
      }
      final decodedBody = jsonDecode(response.body);
      return decodedBody;
    } on http.ClientException catch (e,s) {
      AppLogger.logError("Network error using _sendForAnalysis", error: e, stackTrace: s, tag: _tag);
      throw NetworkException("Network error sending document for analysis (old endpoint): ${e.message}", details: e);
    } on FormatException catch (e,s) {
      AppLogger.logError("Error parsing _sendForAnalysis response", error: e, stackTrace: s, tag: _tag);
      throw DocumentProcessingException("Error parsing analysis API response (old endpoint).", details: e.toString());
    } catch (e,s) {
      AppLogger.logError("Unexpected error in _sendForAnalysis", error: e, stackTrace: s, tag: _tag);
      if (e is AppException) rethrow;
      throw AIAnalysisException("An unexpected error occurred sending document for analysis (old endpoint).", details: e.toString());
    }
  }

  // --- Implementation of TODOs using GeminiService ---

  Future<String> extractCitations(Document document) async {
    AppLogger.logInfo("Starting citation extraction for document: ${document.id}", tag: _tag);
    try {
      final text = await _extractTextFromPdf(document.filePath);
      if (text.isEmpty) {
        AppLogger.logWarning("Document text is empty for citation extraction: ${document.id}", tag: _tag);
        return "Document is empty or text could not be extracted. Citations cannot be determined.";
      }
      const prompt = "Extract all citations and references from the following text. List them clearly, each on a new line. If no citations are found, state that explicitly.";
      final result = await _geminiService.generateTextAnalysis(text, prompt: prompt);
      AppLogger.logInfo("Citation extraction successful for document: ${document.id}", tag: _tag);
      return result;
    } on AIAnalysisException catch (e,s) { // Errors from GeminiService
      AppLogger.logError("AIAnalysisException during citation extraction for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      rethrow; // Rethrow the specific exception
    } on DocumentProcessingException catch (e,s) { // Errors from _extractTextFromPdf
      AppLogger.logError("DocumentProcessingException during citation extraction for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      throw AIAnalysisException("Could not extract citations: Error processing document.", details: e);
    } catch (e, s) {
      AppLogger.logError("Unexpected error during citation extraction for ${document.id}", error: e, stackTrace: s, tag: _tag);
      throw AIAnalysisException("An unexpected error occurred while extracting citations.", details: e.toString());
    }
  }

  Future<String> generateSummary(Document document) async {
    AppLogger.logInfo("Starting summary generation for document: ${document.id}", tag: _tag);
    try {
      final text = await _extractTextFromPdf(document.filePath);
      if (text.isEmpty) {
        AppLogger.logWarning("Document text is empty for summary generation: ${document.id}", tag: _tag);
        return "Document is empty or text could not be extracted. Summary cannot be generated.";
      }
      const prompt = "Summarize the following text in 3-5 concise sentences, focusing on the key findings, methodology, and conclusions. If the text is too short or lacks substance for a summary, state that.";
      final result = await _geminiService.generateTextAnalysis(text, prompt: prompt);
      AppLogger.logInfo("Summary generation successful for document: ${document.id}", tag: _tag);
      return result;
    } on AIAnalysisException catch (e,s) {
      AppLogger.logError("AIAnalysisException during summary generation for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      rethrow;
    } on DocumentProcessingException catch (e,s) {
      AppLogger.logError("DocumentProcessingException during summary generation for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      throw AIAnalysisException("Could not generate summary: Error processing document.", details: e);
    } catch (e, s) {
      AppLogger.logError("Unexpected error during summary generation for ${document.id}", error: e, stackTrace: s, tag: _tag);
      throw AIAnalysisException("An unexpected error occurred while generating the summary.", details: e.toString());
    }
  }

  Future<String> analyzeStatistics(Document document) async {
    AppLogger.logInfo("Starting statistical analysis for document: ${document.id}", tag: _tag);
    try {
      final text = await _extractTextFromPdf(document.filePath);
      if (text.isEmpty) {
        AppLogger.logWarning("Document text is empty for statistical analysis: ${document.id}", tag: _tag);
        return "Document is empty or text could not be extracted. Statistical analysis cannot be performed.";
      }
      const prompt = "Identify and list any key statistics, numerical data, p-values, or quantitative results mentioned in the following text. If possible, briefly explain their significance or context as presented in the text. If no significant statistical data is found, state that explicitly.";
      final result = await _geminiService.generateTextAnalysis(text, prompt: prompt);
      AppLogger.logInfo("Statistical analysis successful for document: ${document.id}", tag: _tag);
      return result;
    } on AIAnalysisException catch (e,s) {
      AppLogger.logError("AIAnalysisException during statistical analysis for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      rethrow;
    } on DocumentProcessingException catch (e,s) {
      AppLogger.logError("DocumentProcessingException during statistical analysis for ${document.id}: ${e.message}", error:e, stackTrace:s, tag: _tag);
      throw AIAnalysisException("Could not analyze statistics: Error processing document.", details: e);
    } catch (e, s) {
      AppLogger.logError("Unexpected error during statistical analysis for ${document.id}", error: e, stackTrace: s, tag: _tag);
      throw AIAnalysisException("An unexpected error occurred while analyzing statistics.", details: e.toString());
    }
  }
}
