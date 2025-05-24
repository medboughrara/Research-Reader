part of 'tts_bloc.dart';

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
