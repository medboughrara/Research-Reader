import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/shared/services/analysis_service.dart';

// Events
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

// States
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
  final Document document;

  const AnalysisSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class AnalysisFailure extends AnalysisState {
  final String error;
  final Document document;

  const AnalysisFailure(this.error, this.document);

  @override
  List<Object?> get props => [error, document];
}

// Bloc
class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final AnalysisService _analysisService;

  AnalysisBloc(this._analysisService) : super(AnalysisInitial()) {
    on<StartAnalysis>(_onStartAnalysis);
  }

  Future<void> _onStartAnalysis(StartAnalysis event, Emitter<AnalysisState> emit) async {
    try {
      emit(AnalysisInProgress(event.document));
      final analyzedDocument = await _analysisService.analyzeDocument(event.document);
      emit(AnalysisSuccess(analyzedDocument));
    } catch (e) {
      emit(AnalysisFailure(e.toString(), event.document));
    }
  }
}
