import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/models/document.dart';
import '../../../shared/services/document_service.dart';
import '../../../shared/di/service_locator.dart';

// Events
abstract class DocumentUploadEvent extends Equatable {
  const DocumentUploadEvent();

  @override
  List<Object> get props => [];
}

class UploadDocumentRequested extends DocumentUploadEvent {
  final String filePath;

  const UploadDocumentRequested(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class DocumentSelectionRequested extends DocumentUploadEvent {}

// States
abstract class DocumentUploadState extends Equatable {
  const DocumentUploadState();

  @override
  List<Object> get props => [];
}

class DocumentUploadInitial extends DocumentUploadState {}

class DocumentUploadInProgress extends DocumentUploadState {}

class DocumentUploadSuccess extends DocumentUploadState {
  final Document document;

  const DocumentUploadSuccess(this.document);

  @override
  List<Object> get props => [document];
}

class DocumentUploadFailure extends DocumentUploadState {
  final String error;

  const DocumentUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}

// BLoC
class DocumentUploadBloc extends Bloc<DocumentUploadEvent, DocumentUploadState> {
  final DocumentService _documentService = getIt<DocumentService>();

  DocumentUploadBloc() : super(DocumentUploadInitial()) {
    on<DocumentSelectionRequested>(_onDocumentSelectionRequested);
    on<UploadDocumentRequested>(_onUploadDocumentRequested);
  }

  Future<void> _onDocumentSelectionRequested(
    DocumentSelectionRequested event,
    Emitter<DocumentUploadState> emit,
  ) async {
    try {
      final document = await _documentService.uploadDocument();
      emit(DocumentUploadSuccess(document));
    } catch (e) {
      emit(DocumentUploadFailure(e.toString()));
    }
  }  Future<void> _onUploadDocumentRequested(
    UploadDocumentRequested event,
    Emitter<DocumentUploadState> emit,
  ) async {
    try {
      emit(DocumentUploadInProgress());
      // This method should be integrated with DocumentService
      // for now, just use the selection method
      final document = await _documentService.uploadDocument();
      emit(DocumentUploadSuccess(document));
    } catch (e) {
      emit(DocumentUploadFailure(e.toString()));
    }
  }
}
