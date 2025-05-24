import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/shared/services/analysis_service.dart';
import '../../../core/utils/logger.dart'; // Added AppLogger
import '../../../core/errors/app_exceptions.dart'; // Added AppExceptions

part 'analysis_event.dart';
part 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final AnalysisService _analysisService;
  static const String _tag = "AnalysisBloc"; // Tag for AppLogger

  AnalysisBloc(this._analysisService) : super(AnalysisInitial()) {
    on<StartAnalysis>(_onStartAnalysis);
  }

  Future<void> _onStartAnalysis(StartAnalysis event, Emitter<AnalysisState> emit) async {
    try {
      emit(AnalysisInProgress(event.document));
      final analyzedDocument = await _analysisService.analyzeDocument(event.document);
      emit(AnalysisSuccess(analyzedDocument));
    } on AIAnalysisException catch (e, s) {
      AppLogger.logError(
        "AI analysis failed for document: ${event.document.id}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(AnalysisFailure("AI analysis failed: ${e.message}", event.document));
    } on NetworkException catch (e, s) {
      AppLogger.logError(
        "Network error during analysis for document: ${event.document.id}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(AnalysisFailure("Network error: Could not complete analysis. Please check your connection.", event.document));
    } on DocumentProcessingException catch (e, s) {
      AppLogger.logError(
        "Document processing error during analysis for document: ${event.document.id}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(AnalysisFailure("Document processing error: ${e.message}", event.document));
    } 
    catch (e, s) {
      AppLogger.logError(
        "Unexpected error during analysis for document: ${event.document.id}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(AnalysisFailure("An unexpected error occurred during analysis. Please try again.", event.document));
    }
  }
}
