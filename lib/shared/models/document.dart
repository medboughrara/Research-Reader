import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'document.g.dart';

@HiveType(typeId: 0)
class Document extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String filePath;
  
  @HiveField(3)
  final int pageCount;
  
  @HiveField(4)
  final DateTime uploadDate;
    @HiveField(5)
  final String? summary;
  
  @HiveField(6)
  final DocumentStatus status;

  @HiveField(7)
  final String? methodology;

  @HiveField(8)
  final Map<String, dynamic>? statistics;

  @HiveField(9)
  final String? futureResearch;

  @HiveField(10)
  final List<String>? citations;

  @HiveField(11)
  final bool isAvailableOffline;

  const Document({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.uploadDate,
    this.summary,
    this.status = DocumentStatus.uploaded,
    this.methodology,
    this.statistics,
    this.futureResearch,
    this.citations,
    this.isAvailableOffline = false,
  });

  @override
  List<Object?> get props => [id, title, filePath, pageCount, uploadDate, summary, status];
  Document copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    DateTime? uploadDate,
    String? summary,
    DocumentStatus? status,
    String? methodology,
    Map<String, dynamic>? statistics,
    String? futureResearch,
    List<String>? citations,
    bool? isAvailableOffline,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      uploadDate: uploadDate ?? this.uploadDate,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      methodology: methodology ?? this.methodology,
      statistics: statistics ?? this.statistics,
      futureResearch: futureResearch ?? this.futureResearch,
      citations: citations ?? this.citations,
      isAvailableOffline: isAvailableOffline ?? this.isAvailableOffline,
    );
  }
}

@HiveType(typeId: 1)
enum DocumentStatus {
  @HiveField(0)
  uploaded,
  @HiveField(1)
  analyzing,
  @HiveField(2)
  analyzed,
  @HiveField(3)
  error
}
