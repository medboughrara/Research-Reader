import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:research_reader/shared/models/analysis_response.dart';

part 'gemini_api_client.g.dart';

@RestApi(baseUrl: "https://generativelanguage.googleapis.com/v1beta")
abstract class GeminiApiClient {
  factory GeminiApiClient(Dio dio, {String? baseUrl}) = _GeminiApiClient;

  @POST("/models/gemini-pro:generateContent")
  Future<AnalysisResponse> generateContent(
    @Header("x-goog-api-key") String apiKey,
    @Body() Map<String, dynamic> request,
  );
}
