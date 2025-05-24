import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

class AnalysisService {
  final DocumentRepository _repository;
  final String _apiEndpoint;

  AnalysisService(this._repository, {String? apiEndpoint})
      : _apiEndpoint = apiEndpoint ?? 'https://api.researchreader.com/analyze';

  Future<Document> analyzeDocument(Document document) async {
    try {
      // Update status to analyzing
      final analyzingDoc = document.copyWith(status: DocumentStatus.analyzing);
      await _repository.saveDocument(analyzingDoc);

      // Extract text from PDF
      final text = await _extractTextFromPdf(document.filePath);
      
      // Send to API for analysis
      final analysis = await _sendForAnalysis(text);
      
      // Update document with analysis results
      final analyzedDoc = document.copyWith(
        status: DocumentStatus.analyzed,
        summary: analysis['summary'],
        // Add other analysis fields here
      );
      
      await _repository.saveDocument(analyzedDoc);
      return analyzedDoc;
    } catch (e) {
      final errorDoc = document.copyWith(status: DocumentStatus.error);
      await _repository.saveDocument(errorDoc);
      rethrow;
    }
  }

  Future<String> _extractTextFromPdf(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = <String>[];

    for (var i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final extractor = PdfTextExtractor(document);
      text.add(await extractor.extractText(startPageIndex: i));
    }

    document.dispose();
    return text.join('\n');
  }

  Future<Map<String, dynamic>> _sendForAnalysis(String text) async {
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
        throw Exception('Analysis failed: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to analyze document: $e');
    }
  }

  Future<List<String>> extractCitations(String text) async {
    // Implement citation extraction logic
    // This could be done locally or via API
    return [];
  }

  Future<String> generateSummary(String text) async {
    // Implement summary generation logic
    // This could be done locally or via API
    return '';
  }

  Future<Map<String, dynamic>> analyzeStatistics(String text) async {
    // Implement statistical analysis logic
    // This could be done locally or via API
    return {};
  }
}
