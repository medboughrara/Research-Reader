import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/models/document.dart';
import '../../../shared/services/document_service.dart';
// import '../../../shared/di/service_locator.dart'; // No longer using getIt here
import '../../../core/utils/logger.dart'; // Added AppLogger
import '../../../core/errors/app_exceptions.dart'; // Added AppExceptions

part 'document_upload_event.dart';
part 'document_upload_state.dart';

// BLoC
class DocumentUploadBloc extends Bloc<DocumentUploadEvent, DocumentUploadState> {
  final DocumentService _documentService;
  static const String _tag = "DocumentUploadBloc"; // Tag for AppLogger

  // Modified constructor to accept DocumentService via DI
  DocumentUploadBloc({required DocumentService documentService}) 
      : _documentService = documentService,
        super(DocumentUploadInitial()) {
    on<DocumentSelectionRequested>(_onDocumentSelectionRequested);
    on<UploadDocumentRequested>(_onUploadDocumentRequested);
  }

  Future<void> _onDocumentSelectionRequested(
    DocumentSelectionRequested event,
    Emitter<DocumentUploadState> emit,
  ) async {
    try {
      emit(DocumentUploadInProgress()); // Indicate progress
      final document = await _documentService.uploadDocument();
      emit(DocumentUploadSuccess(document));
    } on DocumentProcessingException catch (e, s) {
      AppLogger.logError(
        "Document processing error during selection/upload: ${e.message}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(DocumentUploadFailure("Failed to process document: ${e.message}"));
    } on StorageException catch (e, s) {
      AppLogger.logError(
        "Storage error during document selection/upload: ${e.message}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(DocumentUploadFailure("Could not save document: ${e.message} Please check storage and permissions."));
    } catch (e, s) {
      AppLogger.logError(
        "Unexpected error during document selection/upload.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const DocumentUploadFailure("An unexpected error occurred while uploading the document. Please try again."));
    }
  }  
  
  Future<void> _onUploadDocumentRequested(
    UploadDocumentRequested event,
    Emitter<DocumentUploadState> emit,
  ) async {
    // This event handler currently calls the same method as DocumentSelectionRequested.
    // If UploadDocumentRequested is meant to handle a file path directly (e.g., from drag-and-drop
    // that doesn't use FilePicker.platform.pickFiles), its logic would be different.
    // For now, it mirrors _onDocumentSelectionRequested as it calls _documentService.uploadDocument()
    // which internally handles file picking. If `event.filePath` were to be used,
    // `_documentService` would need a method like `saveUploadedFile(String filePath)`.
    // Assuming the current behavior of using file picker is intended for both events:
    try {
      emit(DocumentUploadInProgress());
      AppLogger.logInfo("UploadDocumentRequested event received, filePath: ${event.filePath} (Note: filePath currently not used directly, file picker is invoked by service)", tag: _tag);
      final document = await _documentService.uploadDocument(); // This invokes file picker
      emit(DocumentUploadSuccess(document));
    } on DocumentProcessingException catch (e, s) {
      AppLogger.logError(
        "Document processing error during upload: ${e.message}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(DocumentUploadFailure("Failed to process document: ${e.message}"));
    } on StorageException catch (e, s) {
      AppLogger.logError(
        "Storage error during document upload: ${e.message}",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(DocumentUploadFailure("Could not save document: ${e.message} Please check storage and permissions."));
    } catch (e, s) {
      AppLogger.logError(
        "Unexpected error during document upload.",
        error: e,
        stackTrace: s,
        tag: _tag,
      );
      emit(const DocumentUploadFailure("An unexpected error occurred while uploading the document. Please try again."));
    }
  }
}
