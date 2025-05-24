part of 'settings_bloc.dart';

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
