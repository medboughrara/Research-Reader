import 'package:dio/dio.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:research_reader/core/config/app_environment.dart';
import 'package:research_reader/core/network/gemini_api_client.dart';
import '../../shared/models/analysis_response.dart';
import '../../core/errors/app_exceptions.dart'; 

class GeminiService {
  final GeminiApiClient _client;
  final FlutterSecureStorage _secureStorage;
  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const int _maxOutputTokens = 2048; // Renamed for clarity and used

  GeminiService(this._secureStorage)
      : _client = GeminiApiClient(
          Dio()
            ..interceptors.add(
              InterceptorsWrapper(
                onRequest: (options, handler) async {
                  String? apiKey = await _secureStorage.read(key: _apiKeyStorageKey);
                  options.headers['x-goog-api-key'] = apiKey ?? AppEnvironment.geminiApiKey; 
                  handler.next(options);
                },
              ),
            ),
        );

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
    } on PlatformException catch (e) {
      throw StorageException("Failed to save API key to secure storage.", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException("An unexpected error occurred while saving API key.", details: e.toString());
    }
  }

  Future<String?> getApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeyStorageKey);
    } on PlatformException catch (e) {
      throw StorageException("Failed to read API key from secure storage.", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException("An unexpected error occurred while reading API key.", details: e.toString());
    }
  }

  Future<bool> hasApiKey() async {
    try {
      final apiKey = await _secureStorage.read(key: _apiKeyStorageKey);
      return apiKey != null && apiKey.isNotEmpty;
    } on PlatformException catch (e) {
      throw StorageException("Failed to check for API key in secure storage.", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException("An unexpected error occurred while checking for API key.", details: e.toString());
    }
  }
  
  Future<void> deleteApiKey() async {
    try {
      await _secureStorage.delete(key: _apiKeyStorageKey);
    } on PlatformException catch (e) {
      throw StorageException("Failed to delete API key from secure storage.", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException("An unexpected error occurred while deleting API key.", details: e.toString());
    }
  }

  Future<String> generateTextAnalysis(String text, {String prompt = ''}) async {
    String? apiKey;
    try {
      apiKey = await getApiKey(); 
      if (apiKey == null || apiKey.isEmpty) {
        apiKey = AppEnvironment.geminiApiKey; 
        if (apiKey.isEmpty) {
            throw AIAnalysisException('Gemini API key is not configured. Please set it in the app settings.');
        }
      }

      // Explicitly type the request map and its nested structures
      final Map<String, dynamic> request = {
        'contents': [
          {
            'parts': [
              {'text': '''Analyze the following research paper text. 
                        $prompt
                        Text: $text'''}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': _maxOutputTokens, // Used the constant
        },
        'safetySettings': [ // Ensure this list contains Map<String, String> or Map<String, Object>
          <String, String>{ // Explicitly typed map
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          <String, String>{
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          <String, String>{
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          <String, String>{
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await _client.generateContent(apiKey, request);
      
      if (response.contents.isNotEmpty && response.contents[0].parts.isNotEmpty) {
        return response.contents[0].parts[0].text;
      } else {
        throw AIAnalysisException('Received an empty or malformed response from Gemini API.');
      }
    } on DioException catch (e) {
      throw NetworkException('Network error during Gemini text analysis: ${e.message}', details: e);
    } on AIAnalysisException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AIAnalysisException('An unexpected error occurred during Gemini text analysis.', details: e.toString());
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

    try {
      final result = await generateTextAnalysis(text, prompt: prompt);
      return AnalysisResponse(contents: [
        Content(
          parts: [Part(text: result)],
          role: 'model',
        ),
      ]);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AIAnalysisException("Failed to analyze paper due to an issue in generating text analysis.", details: e.toString());
    }
  }
}

enum AnalysisType {
  summary,
  methodology,
  statistics,
  citations,
  futureResearch,
}
