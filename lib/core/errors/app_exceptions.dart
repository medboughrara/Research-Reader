abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class DocumentProcessingException extends AppException {
  DocumentProcessingException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class AIAnalysisException extends AppException {
  AIAnalysisException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class TTSException extends AppException {
  TTSException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}
