import 'package:flutter/foundation.dart'; // For kDebugMode

class AppLogger {
  static String? _resolveTag(String? tag) {
    if (tag != null) return tag;
    // Consider using runtimeType or other mechanisms if a default tag is needed
    // For simplicity, if no tag is provided, we won't prefix.
    // Alternatively, one could use StackTrace.current to infer the calling class,
    // but that can be expensive and is often overkill for simple logging.
    return null;
  }

  static void logInfo(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = _resolveTag(tag) != null ? '[${_resolveTag(tag)}] ' : '';
      print('${tagPrefix}INFO: $message');
    }
  }

  static void logWarning(String message, {String? tag}) {
    if (kDebugMode) {
      final tagPrefix = _resolveTag(tag) != null ? '[${_resolveTag(tag)}] ' : '';
      print('${tagPrefix}WARNING: $message');
    }
  }

  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (kDebugMode) {
      final tagPrefix = _resolveTag(tag) != null ? '[${_resolveTag(tag)}] ' : '';
      print('${tagPrefix}ERROR: $message');
      if (error != null) {
        print('${tagPrefix}  Error: $error');
      }
      if (stackTrace != null) {
        print('${tagPrefix}  StackTrace: $stackTrace');
      }
    }
  }
}
