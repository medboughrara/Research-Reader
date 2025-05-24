import 'package:dio/dio.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/app_exceptions.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  ApiClient()
      : _dio = Dio(),
        _secureStorage = const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final apiKey = await _getApiKey(options.path);
            if (apiKey != null) {
              options.headers['Authorization'] = 'Bearer $apiKey';
            }
            return handler.next(options);
          } on StorageException catch (e) {
            // If API key retrieval fails, convert to a DioException to be handled by onError
            // Or handle differently if a request shouldn't proceed without a key
            final dioError = DioException(
              requestOptions: options,
              error: e,
              message: "Failed to retrieve API key for request: ${e.message}",
            );
            return handler.reject(dioError); 
          } catch (e) {
             final dioError = DioException(
              requestOptions: options,
              error: e,
              message: "Unexpected error during API key retrieval: ${e.toString()}",
            );
            return handler.reject(dioError);
          }
        },
        onError: (DioException e, handler) {
          // _handleError will throw the appropriate NetworkException
          // We just need to make sure it's passed to the handler correctly.
          try {
            _handleDioError(e); // This will throw a NetworkException
          } catch (customException) {
             if (customException is DioException) { // If _handleDioError rethrows a DioException (it shouldn't)
                return handler.next(customException);
             }
            // To fit it into Dio's error handling flow, wrap custom AppExceptions
            // in a DioException. The service layer calling ApiClient will then unwrap it.
            // This is a common pattern if the interceptor must pass a DioException.
            final enrichedDioError = DioException(
                requestOptions: e.requestOptions,
                error: customException, // Embed our custom exception
                message: customException.toString(),
                response: e.response,
                type: e.type);
            return handler.reject(enrichedDioError);
          }
        },
      ),
    );
  }

  Future<String?> _getApiKey(String path) async {
    try {
      if (path.contains('gemini')) { // This logic for key selection is very basic
        return await _secureStorage.read(key: 'GEMINI_API_KEY');
      } else if (path.contains('texttospeech') || path.contains('magpie-tts')) { // Added magpie-tts for Nvidia
        return await _secureStorage.read(key: 'TTS_API_KEY'); // Assuming a generic TTS key or specific Nvidia key
      }
      // Potentially, other keys for other services if this ApiClient is very generic.
      return null;
    } on PlatformException catch (e) {
      throw StorageException("Failed to access secure storage for API key.", details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException("An unexpected error occurred while retrieving API key.", details: e.toString());
    }
  }

  // This method now directly throws the custom NetworkException.
  Never _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('Connection timeout. Please check your internet connection.', details: error);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        // final data = error.response?.data; // Data can be large, log it or handle carefully
        String message = 'Server error occurred.';
        if (statusCode == 401 || statusCode == 403) {
          message = 'Unauthorized or Forbidden. Please check your API key or permissions.';
        } else if (statusCode == 404) {
          message = 'Resource not found on the server.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error (code $statusCode). Please try again later.';
        } else if (statusCode != null) {
          message = 'Received an invalid response from server (code $statusCode).';
        }
        throw NetworkException(
          message,
          code: statusCode?.toString(),
          details: error, // Keep original DioException for details
        );
      case DioExceptionType.cancel:
        throw NetworkException('Request was cancelled.', details: error);
      case DioExceptionType.connectionError:
         throw NetworkException('Connection error. Please check your internet connection.', details: error);
      case DioExceptionType.unknown:
      default:
        // If the error already contains our custom exception, rethrow it directly.
        if (error.error is AppException) {
            throw error.error as AppException;
        }
        throw NetworkException('An unexpected network error occurred. Please try again.', details: error);
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e); // This will throw, so the function effectively ends here.
    } catch (e) { // Catch non-Dio errors from the request attempt itself
      if (e is AppException) rethrow;
      throw NetworkException("An unexpected error occurred during GET request.", details: e.toString());
    }
  }

  Future<Response<T>> post<T>(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e); // This will throw.
    } catch (e) { // Catch non-Dio errors
      if (e is AppException) rethrow;
      throw NetworkException("An unexpected error occurred during POST request.", details: e.toString());
    }
  }
}
