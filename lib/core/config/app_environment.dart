import 'package:flutter/foundation.dart';
import 'dev_env_config.dart';

class AppEnvironment {
  static const environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  static String get geminiApiKey => isDevelopment 
      ? DevEnvConfig.devGeminiApiKey 
      : const String.fromEnvironment('GEMINI_API_KEY');

  static String get ttsApiKey => isDevelopment 
      ? DevEnvConfig.devTtsApiKey 
      : const String.fromEnvironment('TTS_API_KEY');

  static String get geminiEndpoint => isDevelopment 
      ? DevEnvConfig.devGeminiEndpoint 
      : 'https://api.researchreader.com/gemini';

  static String get ttsEndpoint => isDevelopment 
      ? DevEnvConfig.devTtsEndpoint 
      : 'https://api.researchreader.com/tts';

  static int get maxCacheSize => isDevelopment 
      ? DevEnvConfig.maxDevCacheSize 
      : 100 * 1024 * 1024;

  static Duration get cacheExpiration => isDevelopment 
      ? DevEnvConfig.devCacheExpiration 
      : const Duration(days: 7);

  static String get storagePath => isDevelopment 
      ? DevEnvConfig.devStoragePath 
      : 'storage';

  static String get databaseName => isDevelopment 
      ? DevEnvConfig.devDatabaseName 
      : 'research_reader.db';

  static void logDevInfo(String message) {
    if (isDevelopment) {
      debugPrint('🔧 [DEV] $message');
    }
  }
}
