import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';
import '../../core/errors/app_exceptions.dart'; // Added import

class DocumentService {
  final DocumentRepository _repository;

  DocumentService(this._repository);

  Future<Document> uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        throw DocumentProcessingException('No file selected or file selection was cancelled.');
      }

      final file = result.files.first;
      if (file.path == null) {
        throw DocumentProcessingException('Selected file has an invalid path.');
      }

      // Copy file to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final newFileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final savedFilePath = '${appDir.path}/$newFileName';
      
      File savedFile;
      try {
        savedFile = await File(file.path!).copy(savedFilePath);
      } on FileSystemException catch (e) {
        throw StorageException("Failed to save uploaded file: ${e.message}", details: e);
      }

      final pageCount = await _getPageCount(savedFile.path);

      final document = Document(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Consider more robust ID generation
        title: file.name,
        filePath: savedFile.path,
        pageCount: pageCount,
        uploadDate: DateTime.now(),
        status: DocumentStatus.uploaded,
      );

      await _repository.saveDocument(document);
      return document;
    } on DocumentProcessingException { // Re-throw specific exceptions
      rethrow;
    } on StorageException {
      rethrow;
    } catch (e) { // Catch-all for other unexpected errors during upload process
      if (e is AppException) rethrow;
      throw DocumentProcessingException("An unexpected error occurred during document upload.", details: e.toString());
    }
  }
  
  Future<int> _getPageCount(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final count = document.pages.count;
      document.dispose();
      return count;
    } on FileSystemException catch (e) {
      throw DocumentProcessingException("File error getting page count: ${e.message}", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      // This could be a PDF parsing error, specific to syncfusion_flutter_pdf
      throw DocumentProcessingException("Failed to get page count from PDF.", details: e.toString());
    }
  }

  Future<List<Document>> getAllDocuments() {
    // Assuming repository handles its own errors or this service is not adding a layer for this call
    return _repository.getAllDocuments();
  }

  Future<Document> getDocument(String id) {
    // Assuming repository handles its own errors
    return _repository.getDocument(id);
  }

  Future<void> deleteDocument(String id) async {
    try {
      final document = await _repository.getDocument(id); // Could throw if doc not found
      await File(document.filePath).delete();
      await _repository.deleteDocument(id);
    } on FileSystemException catch (e) {
      throw StorageException("Failed to delete document file: ${e.message}", details: e);
    } catch (e) { // Catch errors from repository or other unexpected issues
      if (e is AppException) rethrow;
      throw DocumentProcessingException("An unexpected error occurred while deleting document.", details: e.toString());
    }
  }
}
