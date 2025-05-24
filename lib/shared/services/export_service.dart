import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document.dart';

class ExportService {
  Future<void> exportAnalysis(Document document) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${document.title}_analysis.json');

    final analysisData = {
      'title': document.title,
      'summary': document.summary,
      'methodology': document.methodology,
      'statistics': document.statistics,
      'futureResearch': document.futureResearch,
      'citations': document.citations,
      'exportDate': DateTime.now().toIso8601String(),
    };

    await file.writeAsString(jsonEncode(analysisData));
    await Share.shareXFiles([XFile(file.path)], text: 'Research Paper Analysis');
  }

  Future<void> exportAsPdf(Document document) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${document.title}_analysis.pdf');

    // TODO: Implement PDF generation using pdf package
    // This will include formatting the analysis results into a well-structured PDF

    await Share.shareXFiles([XFile(file.path)], text: 'Research Paper Analysis PDF');
  }

  Future<void> exportAsMarkdown(Document document) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${document.title}_analysis.md');

    final markdown = '''
# ${document.title} - Analysis Report
Generated on ${DateTime.now().toString()}

## Summary
${document.summary ?? 'No summary available'}

## Methodology
${document.methodology ?? 'No methodology analysis available'}

## Statistical Findings
${_formatStatistics(document.statistics)}

## Future Research Directions
${document.futureResearch ?? 'No future research suggestions available'}

## Citations
${_formatCitations(document.citations)}
''';

    await file.writeAsString(markdown);
    await Share.shareXFiles([XFile(file.path)], text: 'Research Paper Analysis Markdown');
  }

  String _formatStatistics(Map<String, dynamic>? statistics) {
    if (statistics == null || statistics.isEmpty) {
      return 'No statistical analysis available';
    }

    final buffer = StringBuffer();
    statistics.forEach((key, value) {
      buffer.writeln('- **$key**: $value');
    });
    return buffer.toString();
  }

  String _formatCitations(List<String>? citations) {
    if (citations == null || citations.isEmpty) {
      return 'No citations extracted';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < citations.length; i++) {
      buffer.writeln('${i + 1}. ${citations[i]}');
    }
    return buffer.toString();
  }
}
