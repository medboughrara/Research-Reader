import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/document_repository.dart';
import '../services/document_service.dart';
import '../services/tts_service.dart';
import '../services/analysis_service.dart';
import '../services/cache_service.dart';
import '../services/nvidia_tts_service.dart';
import '../services/gemini_service.dart';
// Import SettingsBloc if it were to be registered
// import '../../features/settings/bloc/settings_bloc.dart';


final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core dependencies
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Add FlutterSecureStorage
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage()); 

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

  getIt.registerSingleton<GeminiService>(
    GeminiService(getIt<FlutterSecureStorage>()), 
  );

  // Updated AnalysisService registration
  getIt.registerSingleton<AnalysisService>(
    AnalysisService(getIt<DocumentRepository>(), getIt<GeminiService>()), 
  );

  getIt.registerSingleton<CacheService>(
    CacheService(getIt<DocumentRepository>()),
  );

  // Blocs - Example if SettingsBloc were registered (it's not, per current analysis)
  // getIt.registerFactory<SettingsBloc>(
  //   () => SettingsBloc(geminiService: getIt<GeminiService>()),
  // );
}
