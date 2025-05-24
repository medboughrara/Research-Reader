part of 'settings_bloc.dart';

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
