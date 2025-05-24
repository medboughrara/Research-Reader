part of 'tts_bloc.dart';

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

class TtsError extends TtsState {
  final String message;

  const TtsError(this.message);

  @override
  List<Object> get props => [message];
}
