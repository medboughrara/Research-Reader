part of 'document_upload_bloc.dart';

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
  final String error; // User-friendly error message

  const DocumentUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}
