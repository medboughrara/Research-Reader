import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/nvidia_tts_service.dart';

// Events
abstract class TtsSettingsEvent extends Equatable {
  const TtsSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTtsSettings extends TtsSettingsEvent {}

class UpdateVoiceSettings extends TtsSettingsEvent {
  final String gender;
  final String emotion;
  final double speakingRate;

  const UpdateVoiceSettings({
    required this.gender,
    required this.emotion,
    required this.speakingRate,
  });

  @override
  List<Object?> get props => [gender, emotion, speakingRate];
}

class TestVoiceSettings extends TtsSettingsEvent {
  final String gender;
  final String emotion;
  final double speakingRate;

  const TestVoiceSettings({
    required this.gender,
    required this.emotion,
    required this.speakingRate,
  });

  @override
  List<Object?> get props => [gender, emotion, speakingRate];
}

// States
abstract class TtsSettingsState extends Equatable {
  const TtsSettingsState();

  @override
  List<Object?> get props => [];
}

class TtsSettingsInitial extends TtsSettingsState {}

class TtsSettingsLoaded extends TtsSettingsState {
  final String gender;
  final String emotion;
  final double speakingRate;
  final bool isTesting;

  const TtsSettingsLoaded({
    required this.gender,
    required this.emotion,
    required this.speakingRate,
    this.isTesting = false,
  });

  @override
  List<Object?> get props => [gender, emotion, speakingRate, isTesting];

  TtsSettingsLoaded copyWith({
    String? gender,
    String? emotion,
    double? speakingRate,
    bool? isTesting,
  }) {
    return TtsSettingsLoaded(
      gender: gender ?? this.gender,
      emotion: emotion ?? this.emotion,
      speakingRate: speakingRate ?? this.speakingRate,
      isTesting: isTesting ?? this.isTesting,
    );
  }
}

class TtsSettingsError extends TtsSettingsState {
  final String error;

  const TtsSettingsError(this.error);

  @override
  List<Object?> get props => [error];
}

// Bloc
class TtsSettingsBloc extends Bloc<TtsSettingsEvent, TtsSettingsState> {
  final NvidiaTtsService _ttsService;
  final SharedPreferences _prefs;

  static const String _genderKey = 'tts_gender';
  static const String _emotionKey = 'tts_emotion';
  static const String _rateKey = 'tts_rate';

  TtsSettingsBloc(this._ttsService, this._prefs) : super(TtsSettingsInitial()) {
    on<LoadTtsSettings>(_onLoadSettings);
    on<UpdateVoiceSettings>(_onUpdateSettings);
    on<TestVoiceSettings>(_onTestSettings);
  }

  Future<void> _onLoadSettings(LoadTtsSettings event, Emitter<TtsSettingsState> emit) async {
    try {
      final gender = _prefs.getString(_genderKey) ?? 'female';
      final emotion = _prefs.getString(_emotionKey) ?? 'neutral';
      final rate = _prefs.getDouble(_rateKey) ?? 1.0;

      emit(TtsSettingsLoaded(
        gender: gender,
        emotion: emotion,
        speakingRate: rate,
      ));
    } catch (e) {
      emit(TtsSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(UpdateVoiceSettings event, Emitter<TtsSettingsState> emit) async {
    try {
      await _prefs.setString(_genderKey, event.gender);
      await _prefs.setString(_emotionKey, event.emotion);
      await _prefs.setDouble(_rateKey, event.speakingRate);

      if (state is TtsSettingsLoaded) {
        final currentState = state as TtsSettingsLoaded;
        emit(currentState.copyWith(
          gender: event.gender,
          emotion: event.emotion,
          speakingRate: event.speakingRate,
        ));
      }
    } catch (e) {
      emit(TtsSettingsError(e.toString()));
    }
  }

  Future<void> _onTestSettings(TestVoiceSettings event, Emitter<TtsSettingsState> emit) async {
    if (state is TtsSettingsLoaded) {
      final currentState = state as TtsSettingsLoaded;
      try {
        emit(currentState.copyWith(isTesting: true));
        
        final voice = NvidiaTtsService.availableVoices[event.gender]![event.emotion]!;
        await _ttsService.synthesizeSpeech(
          text: 'This is a test of the text to speech voice settings.',
          voice: voice,
          speakingRate: event.speakingRate,
        );

        emit(currentState.copyWith(isTesting: false));
      } catch (e) {
        emit(TtsSettingsError(e.toString()));
      }
    }
  }
}
