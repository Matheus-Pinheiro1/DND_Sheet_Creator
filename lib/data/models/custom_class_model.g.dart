// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_class_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomClassModelAdapter extends TypeAdapter<CustomClassModel> {
  @override
  final int typeId = 4;

  @override
  CustomClassModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomClassModel(
      id: fields[0] as String,
      name: fields[1] as String,
      hitDie: fields[2] as int,
      savingThrows: (fields[3] as List?)?.cast<String>(),
      spellcastingAbility: fields[4] as String?,
      description: fields[5] as String,
      features: (fields[6] as List?)?.cast<String>(),
      proficiencies: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomClassModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hitDie)
      ..writeByte(3)
      ..write(obj.savingThrows)
      ..writeByte(4)
      ..write(obj.spellcastingAbility)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.features)
      ..writeByte(7)
      ..write(obj.proficiencies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomClassModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
