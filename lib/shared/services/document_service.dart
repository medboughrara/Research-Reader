import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

class DocumentService {
  final DocumentRepository _repository;

  DocumentService(this._repository);

  Future<Document> uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected');
    }

    final file = result.files.first;
    if (file.path == null) {
      throw Exception('Invalid file path');
    }

    // Copy file to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final savedFile = await File(file.path!).copy(
      '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
    );

    final document = Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: file.name,
      filePath: savedFile.path,
      pageCount: await _getPageCount(savedFile.path),
      uploadDate: DateTime.now(),
      status: DocumentStatus.uploaded,
    );

    await _repository.saveDocument(document);
    return document;
  }
  Future<int> _getPageCount(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final count = document.pages.count;
      document.dispose();
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Document>> getAllDocuments() {
    return _repository.getAllDocuments();
  }

  Future<Document> getDocument(String id) {
    return _repository.getDocument(id);
  }

  Future<void> deleteDocument(String id) async {
    final document = await _repository.getDocument(id);
    await File(document.filePath).delete();
    await _repository.deleteDocument(id);
  }
}
