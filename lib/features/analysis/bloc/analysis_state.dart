part of 'analysis_bloc.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisInProgress extends AnalysisState {
  final Document document;

  const AnalysisInProgress(this.document);

  @override
  List<Object?> get props => [document];
}

class AnalysisSuccess extends AnalysisState {
  final Document document; // Contains the analysis results

  const AnalysisSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class AnalysisFailure extends AnalysisState {
  final String error; // User-friendly error message
  final Document document; // Document that was being analyzed

  const AnalysisFailure(this.error, this.document);

  @override
  List<Object?> get props => [error, document];
}
