import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NvidiaTtsService {
  static const String _baseUrl = 'https://api.nvidia.com/magpie-tts/v1';
  final String _apiKey;
  
  NvidiaTtsService() : _apiKey = EnvConfig.ttsApiKey;

  Future<String> synthesizeSpeech({
    required String text,
    String voice = 'female_neutral', // female_neutral, female_calm, male_neutral, male_calm, male_happy, male_fearful, male_sad, male_angry
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
        // Save the audio file to local storage
        final audioData = response.bodyBytes;
        final file = await _saveAudioFile(audioData);
        return file.path;
      } else {
        throw Exception('Failed to synthesize speech: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error synthesizing speech: $e');
    }
  }

  Future<File> _saveAudioFile(List<uint8> audioData) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/tts_$timestamp.wav';
    final file = File(filePath);
    await file.writeAsBytes(audioData);
    return file;
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
    } catch (e) {
      return false;
    }
  }

  Future<void> preloadVoices() async {
    // Synthesize a short text with each voice to cache them
    const testText = 'Testing voice synthesis.';
    for (var gender in availableVoices.keys) {
      for (var emotion in availableVoices[gender]!.keys) {
        try {
          await synthesizeSpeech(
            text: testText,
            voice: availableVoices[gender]![emotion]!,
          );
        } catch (e) {
          // Ignore errors during preloading
          print('Failed to preload voice: $gender-$emotion');
        }
      }
    }
  }
}
