import 'package:dio/dio.dart';
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
          // Add API keys from secure storage
          final apiKey = await _getApiKey(options.path);
          if (apiKey != null) {
            options.headers['Authorization'] = 'Bearer $apiKey';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Transform Dio errors to our custom exceptions
          final error = _handleError(e);
          return handler.reject(error);
        },
      ),
    );
  }

  Future<String?> _getApiKey(String path) async {
    if (path.contains('gemini')) {
      return await _secureStorage.read(key: 'GEMINI_API_KEY');
    } else if (path.contains('texttospeech')) {
      return await _secureStorage.read(key: 'TTS_API_KEY');
    }
    return null;
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('Connection timeout', details: error);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        throw NetworkException(
          'Server error: ${statusCode ?? "Unknown"}',
          code: statusCode?.toString(),
          details: data,
        );
      case DioExceptionType.cancel:
        throw NetworkException('Request cancelled', details: error);
      default:
        throw NetworkException('Network error occurred', details: error);
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
