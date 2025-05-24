// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 0;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Document(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      pageCount: fields[3] as int,
      uploadDate: fields[4] as DateTime,
      summary: fields[5] as String?,
      status: fields[6] as DocumentStatus,
      methodology: fields[7] as String?,
      statistics: (fields[8] as Map?)?.cast<String, dynamic>(),
      futureResearch: fields[9] as String?,
      citations: (fields[10] as List?)?.cast<String>(),
      isAvailableOffline: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.pageCount)
      ..writeByte(4)
      ..write(obj.uploadDate)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.methodology)
      ..writeByte(8)
      ..write(obj.statistics)
      ..writeByte(9)
      ..write(obj.futureResearch)
      ..writeByte(10)
      ..write(obj.citations)
      ..writeByte(11)
      ..write(obj.isAvailableOffline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentStatusAdapter extends TypeAdapter<DocumentStatus> {
  @override
  final int typeId = 1;

  @override
  DocumentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentStatus.uploaded;
      case 1:
        return DocumentStatus.analyzing;
      case 2:
        return DocumentStatus.analyzed;
      case 3:
        return DocumentStatus.error;
      default:
        return DocumentStatus.uploaded;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentStatus obj) {
    switch (obj) {
      case DocumentStatus.uploaded:
        writer.writeByte(0);
        break;
      case DocumentStatus.analyzing:
        writer.writeByte(1);
        break;
      case DocumentStatus.analyzed:
        writer.writeByte(2);
        break;
      case DocumentStatus.error:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
