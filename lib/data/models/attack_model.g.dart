// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attack_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttackModelAdapter extends TypeAdapter<AttackModel> {
  @override
  final int typeId = 1;

  @override
  AttackModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttackModel(
      name: fields[0] as String,
      attackBonus: fields[1] as String,
      damageDice: fields[2] as String,
      damageType: fields[3] as String,
      range: fields[4] as String,
      properties: fields[5] as String,
      isMagic: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AttackModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.attackBonus)
      ..writeByte(2)
      ..write(obj.damageDice)
      ..writeByte(3)
      ..write(obj.damageType)
      ..writeByte(4)
      ..write(obj.range)
      ..writeByte(5)
      ..write(obj.properties)
      ..writeByte(6)
      ..write(obj.isMagic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttackModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
