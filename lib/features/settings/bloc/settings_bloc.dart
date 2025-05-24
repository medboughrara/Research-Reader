import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../core/utils/logger.dart'; // Added AppLogger
import '../../../core/errors/app_exceptions.dart'; // Added AppExceptions

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GeminiService _geminiService;
  static const String _tag = "SettingsBloc"; // Tag for AppLogger

  SettingsBloc({required GeminiService geminiService})
      : _geminiService = geminiService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateGeminiApiKey>(_onUpdateGeminiApiKey);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final hasKey = await _geminiService.hasApiKey();
      emit(SettingsLoaded(hasGeminiApiKey: hasKey));
    } on StorageException catch (e, s) {
      AppLogger.logError(
        "Failed to load API key status due to storage issue.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const SettingsError("Could not load API key status. Please ensure the application has storage access and try again."));
    } catch (e, s) {
      AppLogger.logError(
        "An unexpected error occurred while loading settings.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const SettingsError("An unexpected error occurred while loading settings. Please restart the app."));
    }
  }

  Future<void> _onUpdateGeminiApiKey(UpdateGeminiApiKey event, Emitter<SettingsState> emit) async {
    try {
      if (event.apiKey.isEmpty) {
        emit(const SettingsError("API key cannot be empty."));
        return;
      }
      
      // Optional: Add a real API key validation call via _geminiService if implemented
      // This would involve _geminiService.validateApiKey(event.apiKey) which could throw e.g. AIAnalysisException or NetworkException
      // For example:
      // try {
      //   final isValid = await _geminiService.validateApiKey(event.apiKey); // Assuming this method exists and makes a test API call
      //   if (!isValid) { // Or if it throws an exception on invalid key
      //     AppLogger.logWarning("Attempted to save an invalid Gemini API key.", tag: _tag);
      //     emit(const SettingsError("The provided API key is not valid. Please check the key and try again."));
      //     return;
      //   }
      // } on NetworkException catch (e,s) {
      //    AppLogger.logError("Network error validating Gemini API key.", error: e, stackTrace: s, tag: _tag);
      //    emit(const SettingsError("Could not validate API key: Network error. Please check your connection."));
      //    return;
      // } on AIAnalysisException catch (e,s) { // If validation itself fails due to API error
      //    AppLogger.logError("API error validating Gemini API key.", error: e, stackTrace: s, tag: _tag);
      //    emit(const SettingsError("Could not validate API key: API error. The key might be incorrect or service unavailable."));
      //    return;
      // }

      await _geminiService.saveApiKey(event.apiKey);
      AppLogger.logInfo("Gemini API key saved successfully.", tag: _tag);
      emit(const SettingsLoaded(hasGeminiApiKey: true));
    } on StorageException catch (e, s) {
      AppLogger.logError(
        "Failed to save API key due to storage issue.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const SettingsError("Failed to save API key. Please ensure the application has storage access and try again."));
    } catch (e, s) {
      AppLogger.logError(
        "An unexpected error occurred while saving the API key.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const SettingsError("An unexpected error occurred while saving the API key. Please try again."));
    }
  }
}
