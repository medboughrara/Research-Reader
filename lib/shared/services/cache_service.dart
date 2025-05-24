import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';

class CacheService {
  final DocumentRepository _repository;
  static const String _cacheDir = 'cached_documents';

  CacheService(this._repository);

  Future<String> get _cachePath async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDir');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<bool> isDocumentCached(String documentId) async {
    try {
      final document = await _repository.getDocument(documentId);
      final cachePath = await _getCacheFilePath(document);
      return File(cachePath).exists();
    } catch (e) {
      return false;
    }
  }

  Future<String> _getCacheFilePath(Document document) async {
    final cache = await _cachePath;
    return '$cache/${document.id}_${document.title}';
  }

  Future<void> cacheDocument(Document document) async {
    try {
      // Copy file to cache directory
      final cachePath = await _getCacheFilePath(document);
      await File(document.filePath).copy(cachePath);

      // Update document status
      final cachedDoc = document.copyWith(isAvailableOffline: true);
      await _repository.saveDocument(cachedDoc);
    } catch (e) {
      throw Exception('Failed to cache document: $e');
    }
  }

  Future<void> removeCachedDocument(Document document) async {
    try {
      final cachePath = await _getCacheFilePath(document);
      final cacheFile = File(cachePath);
      
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }

      // Update document status
      final uncachedDoc = document.copyWith(isAvailableOffline: false);
      await _repository.saveDocument(uncachedDoc);
    } catch (e) {
      throw Exception('Failed to remove cached document: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final cache = await _cachePath;
      final cacheDir = Directory(cache);
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      // Update all documents to uncached
      final documents = await _repository.getAllDocuments();
      for (final doc in documents) {
        if (doc.isAvailableOffline) {
          final uncachedDoc = doc.copyWith(isAvailableOffline: false);
          await _repository.saveDocument(uncachedDoc);
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  Future<String> getCachedFilePath(String documentId) async {
    final document = await _repository.getDocument(documentId);
    if (!document.isAvailableOffline) {
      throw Exception('Document is not cached');
    }
    return _getCacheFilePath(document);
  }
}
