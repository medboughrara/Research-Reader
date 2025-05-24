import 'package:hive_flutter/hive_flutter.dart';
import '../models/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getAllDocuments();
  Future<Document> getDocument(String id);
  Future<void> saveDocument(Document document);
  Future<void> deleteDocument(String id);
}

class HiveDocumentRepository implements DocumentRepository {
  static const String _boxName = 'documents';
  late Box<Document> _box;

  Future<void> initialize() async {
    Hive.registerAdapter(DocumentAdapter());
    Hive.registerAdapter(DocumentStatusAdapter());
    _box = await Hive.openBox<Document>(_boxName);
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    return _box.values.toList();
  }

  @override
  Future<Document> getDocument(String id) async {
    final document = _box.get(id);
    if (document == null) {
      throw Exception('Document not found');
    }
    return document;
  }

  @override
  Future<void> saveDocument(Document document) async {
    await _box.put(document.id, document);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _box.delete(id);
  }
}
