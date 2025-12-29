// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanResultModelAdapter extends TypeAdapter<ScanResultModel> {
  @override
  final int typeId = 0;

  @override
  ScanResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResultModel(
      value: fields[0] as String,
      scannedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResultModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.scannedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
