class DevEnvConfig {
  static const bool isDevelopment = true;
  
  // Development API Endpoints
  static const String devGeminiEndpoint = 'https://dev-api.researchreader.com/gemini';
  static const String devTtsEndpoint = 'https://dev-api.researchreader.com/tts';
  
  // Development API Keys
  static const String devGeminiApiKey = 'AIzaSyDZHuaCbJHL6zlNQWJ2nUG3ggEgcIgUxPU_DEV';
  static const String devTtsApiKey = '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';
  
  // Development Feature Flags
  static const bool enableDebugLogging = true;
  static const bool mockApiResponses = true;
  static const bool enableTestFeatures = true;
  
  // Development Cache Settings
  static const int maxDevCacheSize = 20 * 1024 * 1024; // 20MB for dev
  static const Duration devCacheExpiration = Duration(hours: 1);
  
  // Development Paths
  static const String devStoragePath = 'dev_storage';
  static const String devDatabaseName = 'research_reader_dev.db';
}
