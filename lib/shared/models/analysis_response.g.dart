// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResponse _$AnalysisResponseFromJson(Map<String, dynamic> json) =>
    AnalysisResponse(
      contents: (json['contents'] as List<dynamic>)
          .map((e) => Content.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalysisResponseToJson(AnalysisResponse instance) =>
    <String, dynamic>{
      'contents': instance.contents,
    };

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      parts: (json['parts'] as List<dynamic>)
          .map((e) => Part.fromJson(e as Map<String, dynamic>))
          .toList(),
      role: json['role'] as String,
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'parts': instance.parts,
      'role': instance.role,
    };

Part _$PartFromJson(Map<String, dynamic> json) => Part(
      text: json['text'] as String,
    );

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
      'text': instance.text,
    };
