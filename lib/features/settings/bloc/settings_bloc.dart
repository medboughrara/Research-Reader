import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/config/env_config.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateGeminiApiKey extends SettingsEvent {
  final String apiKey;

  const UpdateGeminiApiKey(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class LoadSettings extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool hasGeminiApiKey;

  const SettingsLoaded({
    required this.hasGeminiApiKey,
  });

  @override
  List<Object?> get props => [hasGeminiApiKey];
}

class SettingsError extends SettingsState {
  final String error;

  const SettingsError(this.error);

  @override
  List<Object?> get props => [error];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateGeminiApiKey>(_onUpdateGeminiApiKey);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final geminiApiKey = EnvConfig.geminiApiKey;
      emit(SettingsLoaded(
        hasGeminiApiKey: geminiApiKey.isNotEmpty,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateGeminiApiKey(UpdateGeminiApiKey event, Emitter<SettingsState> emit) async {
    try {
      if (event.apiKey.isEmpty) {
        throw Exception('API key cannot be empty');
      }

      // Test the API key by making a simple request
      final geminiService = GeminiService();
      await geminiService.generateTextAnalysis(
        'Test request to validate API key',
        prompt: 'Respond with "OK" if the API key is valid.',
      );

      emit(SettingsLoaded(hasGeminiApiKey: true));
    } catch (e) {
      emit(SettingsError('Invalid API key: ${e.toString()}'));
    }
  }
}
