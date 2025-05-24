import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/tts_service.dart';
import '../../../shared/models/document.dart';
import '../../../core/utils/logger.dart'; // Added AppLogger
import '../../../core/errors/app_exceptions.dart'; // Added AppExceptions

part 'tts_event.dart';
part 'tts_state.dart';

class TtsBloc extends Bloc<TtsEvent, TtsState> {
  final TTSService _ttsService;
  static const String _tag = "TtsBloc"; // Tag for AppLogger

  TtsBloc(this._ttsService) : super(TtsInitial()) {
    on<StartReading>(_onStartReading);
    on<PauseReading>(_onPauseReading);
    on<ContinueReading>(_onContinueReading);
    on<StopReading>(_onStopReading);
    on<UpdateVoice>(_onUpdateVoice);
    on<UpdateSpeechRate>(_onUpdateSpeechRate);
  }

  Future<void> _onStartReading(StartReading event, Emitter<TtsState> emit) async {
    try {
      await _ttsService.speak(event.text, event.document.id);
      emit(TtsPlaying(event.document, 0)); // Assuming progress starts at 0
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error starting reading", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not start text-to-speech: ${e.message}"));
    } on StorageException catch (e,s){
      AppLogger.logError("Storage error during TTS start", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("Could not start text-to-speech due to a storage problem. Please check file access."));
    } 
    catch (e, s) {
      AppLogger.logError("Unexpected error starting reading", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to start text-to-speech."));
    }
  }

  Future<void> _onPauseReading(PauseReading event, Emitter<TtsState> emit) async {
    try {
      if (state is TtsPlaying) {
        final playingState = state as TtsPlaying;
        await _ttsService.pause();
        // Corrected: _ttsService.progress is non-nullable
        emit(TtsPaused(playingState.document, _ttsService.progress)); 
      }
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error pausing reading", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not pause text-to-speech: ${e.message}"));
    } catch (e, s) {
      AppLogger.logError("Unexpected error pausing reading", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to pause text-to-speech."));
    }
  }

  Future<void> _onContinueReading(ContinueReading event, Emitter<TtsState> emit) async {
    try {
      if (state is TtsPaused) {
        final pausedState = state as TtsPaused;
        await _ttsService.continueReading();
        // Assuming continueReading might update progress, or it remains from pausedState
        emit(TtsPlaying(pausedState.document, _ttsService.progress)); 
      }
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error continuing reading", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not continue text-to-speech: ${e.message}"));
    } catch (e, s) {
      AppLogger.logError("Unexpected error continuing reading", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to continue text-to-speech."));
    }
  }

  Future<void> _onStopReading(StopReading event, Emitter<TtsState> emit) async {
    try {
      await _ttsService.stop();
      emit(TtsStopped());
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error stopping reading", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not stop text-to-speech: ${e.message}"));
    } catch (e, s) {
      AppLogger.logError("Unexpected error stopping reading", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to stop text-to-speech."));
    }
  }

  Future<void> _onUpdateVoice(UpdateVoice event, Emitter<TtsState> emit) async {
    try {
      await _ttsService.setVoice(event.voice);
      // Optionally, emit a state to confirm voice change if UI needs to react
      // emit(TtsSettingsUpdated()); // Example
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error updating voice", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not update voice: ${e.message}"));
    } catch (e, s) {
      AppLogger.logError("Unexpected error updating voice", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to update voice settings."));
    }
  }

  Future<void> _onUpdateSpeechRate(UpdateSpeechRate event, Emitter<TtsState> emit) async {
    try {
      await _ttsService.setSpeechRate(event.rate);
      // Optionally, emit a state to confirm rate change
      // emit(TtsSettingsUpdated()); // Example
    } on TTSException catch (e, s) {
      AppLogger.logError("TTS error updating speech rate", error: e, stackTrace: s, tag: _tag);
      emit(TtsError("Could not update speech rate: ${e.message}"));
    } catch (e, s) {
      AppLogger.logError("Unexpected error updating speech rate", error: e, stackTrace: s, tag: _tag);
      emit(const TtsError("An unexpected error occurred while trying to update speech rate."));
    }
  }
}
