class EnvConfig {
  static const String geminiApiKey = String.fromEnvironment('AIzaSyDZHuaCbJHL6zlNQWJ2nUG3ggEgcIgUxPU');
  static const String ttsApiKey = String.fromEnvironment('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');
  
  // API Endpoints
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String ttsEndpoint = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBackupAPIs = true;
  
  // Cache Configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiration = Duration(days: 7);
}
