import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/document_repository.dart';
import '../services/document_service.dart';
import '../services/tts_service.dart';
import '../services/analysis_service.dart';
import '../services/cache_service.dart';
import '../services/nvidia_tts_service.dart';
import '../services/gemini_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core dependencies
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Repositories
  final documentRepo = HiveDocumentRepository();
  await documentRepo.initialize();
  getIt.registerSingleton<DocumentRepository>(documentRepo);
  // Services
  getIt.registerSingleton<DocumentService>(
    DocumentService(getIt<DocumentRepository>()),
  );
  
  getIt.registerSingleton<TTSService>(
    TTSService(getIt<SharedPreferences>()),
  );

  getIt.registerSingleton<NvidiaTtsService>(
    NvidiaTtsService(),
  );

  getIt.registerSingleton<AnalysisService>(
    AnalysisService(getIt<DocumentRepository>()),
  );

  getIt.registerSingleton<CacheService>(
    CacheService(getIt<DocumentRepository>()),
  );

  getIt.registerSingleton<GeminiService>(
    GeminiService(),
  );
}
