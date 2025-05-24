part of 'document_upload_bloc.dart';

abstract class DocumentUploadEvent extends Equatable {
  const DocumentUploadEvent();

  @override
  List<Object> get props => [];
}

class UploadDocumentRequested extends DocumentUploadEvent {
  final String filePath; // This might be redundant if selection is done within the bloc

  const UploadDocumentRequested(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// This event seems more appropriate for triggering the file picking process
class DocumentSelectionRequested extends DocumentUploadEvent {}
