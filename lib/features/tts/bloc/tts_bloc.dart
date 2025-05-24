import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../shared/services/tts_service.dart';
import '../../shared/models/document.dart';

// Events
abstract class TtsEvent extends Equatable {
  const TtsEvent();

  @override
  List<Object?> get props => [];
}

class StartReading extends TtsEvent {
  final Document document;
  final String text;

  const StartReading(this.document, this.text);

  @override
  List<Object?> get props => [document, text];
}

class PauseReading extends TtsEvent {}

class ContinueReading extends TtsEvent {}

class StopReading extends TtsEvent {}

class UpdateVoice extends TtsEvent {
  final String voice;

  const UpdateVoice(this.voice);

  @override
  List<Object?> get props => [voice];
}

class UpdateSpeechRate extends TtsEvent {
  final double rate;

  const UpdateSpeechRate(this.rate);

  @override
  List<Object?> get props => [rate];
}

// States
abstract class TtsState extends Equatable {
  const TtsState();

  @override
  List<Object?> get props => [];
}

class TtsInitial extends TtsState {}

class TtsPlaying extends TtsState {
  final Document document;
  final double progress;

  const TtsPlaying(this.document, this.progress);

  @override
  List<Object?> get props => [document, progress];
}

class TtsPaused extends TtsState {
  final Document document;
  final double progress;

  const TtsPaused(this.document, this.progress);

  @override
  List<Object?> get props => [document, progress];
}

class TtsStopped extends TtsState {}

// Bloc
class TtsBloc extends Bloc<TtsEvent, TtsState> {
  final TTSService _ttsService;

  TtsBloc(this._ttsService) : super(TtsInitial()) {
    on<StartReading>(_onStartReading);
    on<PauseReading>(_onPauseReading);
    on<ContinueReading>(_onContinueReading);
    on<StopReading>(_onStopReading);
    on<UpdateVoice>(_onUpdateVoice);
    on<UpdateSpeechRate>(_onUpdateSpeechRate);
  }

  Future<void> _onStartReading(StartReading event, Emitter<TtsState> emit) async {
    await _ttsService.speak(event.text, event.document.id);
    emit(TtsPlaying(event.document, 0));
  }

  Future<void> _onPauseReading(PauseReading event, Emitter<TtsState> emit) async {
    if (state is TtsPlaying) {
      final playingState = state as TtsPlaying;
      await _ttsService.pause();
      emit(TtsPaused(playingState.document, _ttsService.progress));
    }
  }

  Future<void> _onContinueReading(ContinueReading event, Emitter<TtsState> emit) async {
    if (state is TtsPaused) {
      final pausedState = state as TtsPaused;
      await _ttsService.continueReading();
      emit(TtsPlaying(pausedState.document, pausedState.progress));
    }
  }

  Future<void> _onStopReading(StopReading event, Emitter<TtsState> emit) async {
    await _ttsService.stop();
    emit(TtsStopped());
  }

  Future<void> _onUpdateVoice(UpdateVoice event, Emitter<TtsState> emit) async {
    await _ttsService.setVoice(event.voice);
  }

  Future<void> _onUpdateSpeechRate(UpdateSpeechRate event, Emitter<TtsState> emit) async {
    await _ttsService.setSpeechRate(event.rate);
  }
}
