part of 'analysis_bloc.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class StartAnalysis extends AnalysisEvent {
  final Document document;

  const StartAnalysis(this.document);

  @override
  List<Object?> get props => [document];
}
