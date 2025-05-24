import 'package:dio/dio.dart';
import 'package:research_reader/core/config/app_environment.dart';
import 'package:research_reader/core/network/gemini_api_client.dart';
import '../../shared/models/analysis_response.dart';

class GeminiService {
  final GeminiApiClient _client;
  static const int _maxTokens = 2048;

  GeminiService({String? apiKey})
      : _client = GeminiApiClient(
          Dio()
            ..interceptors.add(
              InterceptorsWrapper(
                onRequest: (options, handler) {
                  options.headers['x-goog-api-key'] = apiKey ?? AppEnvironment.geminiApiKey;
                  handler.next(options);
                },
              ),
            ),
        );
  Future<String> generateTextAnalysis(String text, {String prompt = ''}) async {
    try {
      final request = {
        'contents': [{
          'parts': [{
            'text': '''Analyze the following research paper text. 
                      $prompt
                      Text: $text'''
          }]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': _maxTokens,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await _client.generateContent(
        AppEnvironment.geminiApiKey,
        request,
      );
      
      if (response.contents.isNotEmpty && response.contents[0].parts.isNotEmpty) {
        return response.contents[0].parts[0].text;
      } else {
        throw Exception('Empty response from Gemini API');
      }
    } catch (e) {
      throw Exception('Error analyzing text: $e');
    }
  }

  Future<AnalysisResponse> analyzePaper({
    required String text,
    required AnalysisType type,
  }) async {
    String prompt;
    switch (type) {
      case AnalysisType.summary:
        prompt = 'Provide a concise summary of the key findings and conclusions.';
        break;
      case AnalysisType.methodology:
        prompt = 'Identify and explain the research methodology used.';
        break;
      case AnalysisType.statistics:
        prompt = 'Extract and explain the key statistical findings and their significance.';
        break;
      case AnalysisType.citations:
        prompt = 'Extract all citations and references mentioned in the text.';
        break;
      case AnalysisType.futureResearch:
        prompt = 'Identify suggested future research directions and potential extensions of this work.';
        break;
    }

    final result = await generateTextAnalysis(text, prompt: prompt);
    return AnalysisResponse(contents: [
      Content(
        parts: [Part(text: result)],
        role: 'model',
      ),
    ]);
  }
}

enum AnalysisType {
  summary,
  methodology,
  statistics,
  citations,
  futureResearch,
}
