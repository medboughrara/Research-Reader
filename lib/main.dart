import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/theme.dart';
import 'core/config/app_environment.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/tts/presentation/tts_options_screen.dart';
import 'shared/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and dependencies
  await Hive.initFlutter(AppEnvironment.storagePath);
  await setupDependencies();
  
  AppEnvironment.logDevInfo('Starting app in ${AppEnvironment.environment} mode');
  
  runApp(const ResearchReaderApp());
}

class ResearchReaderApp extends StatelessWidget {
  const ResearchReaderApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppEnvironment.isDevelopment 
          ? 'Research Reader (Dev)' 
          : 'Research Reader',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: AppEnvironment.isDevelopment,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/tts-options': (context) => const TtsOptionsScreen(),
      },
    );
  }
}
