import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import '../../shared/models/analysis_response.dart';
import './parse_error_logger.dart'; // Import ParseErrorLogger

part 'analysis_api_client.g.dart';

const _contentTypeJson = {"Content-Type": "application/json"};

@RestApi(baseUrl: "https://generativelanguage.googleapis.com/v1beta")
abstract class AnalysisApiClient {
  factory AnalysisApiClient(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) = _AnalysisApiClient; // Add errorLogger
  @POST("/models/gemini-pro:generateContent")
  @Headers(_contentTypeJson)
  Future<AnalysisResponse> summarizeText(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );

  @POST("/models/gemini-pro:generateContent")
  @Headers(_contentTypeJson)
  Future<AnalysisResponse> analyzeMethodology(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );

  @POST("/models/gemini-pro:generateContent")
  @Headers(_contentTypeJson)
  Future<AnalysisResponse> analyzeStatistics(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );

  @POST("/models/gemini-pro:generateContent")
  @Headers(_contentTypeJson)
  Future<AnalysisResponse> extractCitations(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );

  @POST("/models/gemini-pro:generateContent")
  @Headers(_contentTypeJson)
  Future<AnalysisResponse> suggestFutureResearch(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );
}
