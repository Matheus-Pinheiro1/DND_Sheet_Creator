// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_race_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomRaceModelAdapter extends TypeAdapter<CustomRaceModel> {
  @override
  final int typeId = 2;

  @override
  CustomRaceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomRaceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      speed: fields[2] as int,
      size: fields[3] as String,
      traits: (fields[4] as List?)?.cast<String>(),
      abilityBonuses: fields[5] as String,
      languages: (fields[6] as List?)?.cast<String>(),
      description: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomRaceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.speed)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.traits)
      ..writeByte(5)
      ..write(obj.abilityBonuses)
      ..writeByte(6)
      ..write(obj.languages)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomRaceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
