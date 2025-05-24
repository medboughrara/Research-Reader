import 'package:json_annotation/json_annotation.dart';

part 'analysis_response.g.dart';

@JsonSerializable()
class AnalysisResponse {
  final List<Content> contents;

  AnalysisResponse({required this.contents});

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResponseToJson(this);
}

@JsonSerializable()
class Content {
  final List<Part> parts;
  final String role;

  Content({required this.parts, required this.role});

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

  Map<String, dynamic> toJson() => _$ContentToJson(this);
}

@JsonSerializable()
class Part {
  final String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  Map<String, dynamic> toJson() => _$PartToJson(this);
}
