import 'package:dio/dio.dart'; // Import RequestOptions
import '../utils/logger.dart'; // Import AppLogger

// Placeholder for ParseErrorLogger
// Used by retrofit_generator for custom error parsing.
// Actual implementation would depend on the desired logging strategy.
class ParseErrorLogger {
  void logError(dynamic error, StackTrace stackTrace, RequestOptions options) {
    // In a real implementation, you might log to a service, console, etc.
    AppLogger.logError(
      "Retrofit request failed for path: ${options.path}",
      error: error,
      stackTrace: stackTrace,
      tag: "ParseErrorLogger",
    );
  }

  // The generated code might expect specific methods or a default constructor.
  // Add them if flutter analyze still complains after build_runner.
}
