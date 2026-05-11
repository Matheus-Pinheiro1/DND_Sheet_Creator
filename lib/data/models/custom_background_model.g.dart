// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_background_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomBackgroundModelAdapter extends TypeAdapter<CustomBackgroundModel> {
  @override
  final int typeId = 3;

  @override
  CustomBackgroundModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomBackgroundModel(
      id: fields[0] as String,
      name: fields[1] as String,
      skillProficiencyIndices: (fields[2] as List?)?.cast<String>(),
      featureName: fields[3] as String,
      featureDescription: fields[4] as String,
      description: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomBackgroundModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.skillProficiencyIndices)
      ..writeByte(3)
      ..write(obj.featureName)
      ..writeByte(4)
      ..write(obj.featureDescription)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomBackgroundModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
