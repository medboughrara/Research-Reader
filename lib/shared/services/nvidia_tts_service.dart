import 'dart:convert';
import 'dart:typed_data'; // Added for Uint8List
import 'package:http/http.dart' as http;
import '../../core/config/env_config.dart'; // Corrected path
import '../../core/errors/app_exceptions.dart'; // Added import for custom exceptions
import '../../core/utils/logger.dart'; // Added import for AppLogger
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NvidiaTtsService {
  static const String _baseUrl = 'https://api.nvidia.com/magpie-tts/v1';
  final String _apiKey;
  static const String _tag = "NvidiaTtsService"; // Tag for AppLogger
  
  NvidiaTtsService() : _apiKey = EnvConfig.ttsApiKey;

  Future<String> synthesizeSpeech({
    required String text,
    String voice = 'female_neutral',
    String language = 'en-US',
    double speakingRate = 1.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/synthesize'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'voice': voice,
          'language': language,
          'speaking_rate': speakingRate,
          'audio_config': {
            'encoding': 'LINEAR16',
            'sample_rate_hertz': 22050,
          },
        }),
      );

      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;
        final file = await _saveAudioFile(audioData);
        return file.path;
      } else {
        throw TTSException(
          'Failed to synthesize speech. Status code: ${response.statusCode}',
          code: response.statusCode.toString(),
          details: response.body,
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error during TTS synthesis: ${e.message}', details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw TTSException('An unexpected error occurred during TTS synthesis.', details: e.toString());
    }
  }

  Future<File> _saveAudioFile(Uint8List audioData) async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/tts_$timestamp.wav';
      final file = File(filePath);
      await file.writeAsBytes(audioData);
      return file;
    } catch (e) {
      throw StorageException('Failed to save TTS audio file.', details: e.toString());
    }
  }

  static const availableVoices = {
    'female': {
      'neutral': 'female_neutral',
      'calm': 'female_calm',
    },
    'male': {
      'neutral': 'male_neutral',
      'calm': 'male_calm',
      'happy': 'male_happy',
      'fearful': 'male_fearful',
      'sad': 'male_sad',
      'angry': 'male_angry',
    },
  };

  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/test'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e, s) {
      AppLogger.logError( // Changed to logError
        'NVIDIA TTS testConnection failed. This might be a network issue or invalid API key.', 
        tag: _tag,
        error: e,
        stackTrace: s
      );
      return false;
    }
  }

  Future<void> preloadVoices() async {
    const testText = 'Testing voice synthesis.';
    for (var gender in availableVoices.keys) {
      for (var emotion in availableVoices[gender]!.keys) {
        try {
          await synthesizeSpeech(
            text: testText,
            voice: availableVoices[gender]![emotion]!,
          );
        } catch (e, s) {
          AppLogger.logError( // Changed to logError
            'Failed to preload voice: $gender-$emotion.',
            tag: _tag,
            error: e,
            stackTrace: s,
          );
        }
      }
    }
  }
}
