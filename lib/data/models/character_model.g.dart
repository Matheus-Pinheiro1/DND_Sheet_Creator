// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

class CharacterModelAdapter extends TypeAdapter<CharacterModel> {
  @override
  final int typeId = 0;

  @override
  CharacterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      race: fields[2] as String? ?? '',
      raceName: fields[3] as String? ?? '',
      className: fields[4] as String? ?? '',
      classDisplayName: fields[5] as String? ?? '',
      subclass: fields[6] as String? ?? '',
      subclassName: fields[7] as String? ?? '',
      background: fields[8] as String? ?? '',
      backgroundName: fields[9] as String? ?? '',
      alignment: fields[10] as String? ?? 'True Neutral',
      level: fields[11] as int? ?? 1,
      experiencePoints: fields[12] as int? ?? 0,
      strength: fields[13] as int? ?? 10,
      dexterity: fields[14] as int? ?? 10,
      constitution: fields[15] as int? ?? 10,
      intelligence: fields[16] as int? ?? 10,
      wisdom: fields[17] as int? ?? 10,
      charisma: fields[18] as int? ?? 10,
      maxHP: fields[19] as int? ?? 0,
      currentHP: fields[20] as int? ?? 0,
      temporaryHP: fields[21] as int? ?? 0,
      armorClass: fields[22] as int? ?? 10,
      speed: fields[23] as int? ?? 30,
      initiative: fields[24] as int? ?? 0,
      hitDie: fields[25] as int? ?? 8,
      proficientSkills: (fields[26] as List?)?.cast<String>(),
      savingThrowProfs: (fields[27] as List?)?.cast<String>(),
      selectedSpells: (fields[28] as List?)?.cast<String>(),
      preparedSpells: (fields[29] as List?)?.cast<String>(),
      spellSlotsMax: (fields[30] as List?)?.cast<int>(),
      spellSlotsUsed: (fields[31] as List?)?.cast<int>(),
      personalityTraits: fields[32] as String? ?? '',
      ideals: fields[33] as String? ?? '',
      bonds: fields[34] as String? ?? '',
      flaws: fields[35] as String? ?? '',
      backstory: fields[36] as String? ?? '',
      notes: fields[37] as String? ?? '',
      equipment: (fields[38] as List?)?.cast<String>(),
      copper: fields[39] as int? ?? 0,
      silver: fields[40] as int? ?? 0,
      electrum: fields[41] as int? ?? 0,
      gold: fields[42] as int? ?? 0,
      platinum: fields[43] as int? ?? 0,
      inspiration: fields[44] as bool? ?? false,
      deathSaveSuccesses: fields[45] as int? ?? 0,
      deathSaveFailures: fields[46] as int? ?? 0,
      avatarChoice: fields[47] as String?,
      createdAt: fields[48] as DateTime?,
      updatedAt: fields[49] as DateTime?,
      spellcastingAbility: fields[50] as String? ?? '',
      languages: (fields[51] as List?)?.cast<String>(),
      proficiencies: (fields[52] as List?)?.cast<String>(),
      attacks: (fields[53] as List?)?.cast<AttackModel>(),
      concentrationSpell: fields[54] as String? ?? '',
      backgroundSkillProfs: (fields[55] as List?)?.cast<String>(),
      levelAdvancements: (fields[56] as List?)?.cast<String>(),
      exhaustionLevel: fields[57] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, CharacterModel obj) {
    writer
      ..writeByte(58)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.race)
      ..writeByte(3)
      ..write(obj.raceName)
      ..writeByte(4)
      ..write(obj.className)
      ..writeByte(5)
      ..write(obj.classDisplayName)
      ..writeByte(6)
      ..write(obj.subclass)
      ..writeByte(7)
      ..write(obj.subclassName)
      ..writeByte(8)
      ..write(obj.background)
      ..writeByte(9)
      ..write(obj.backgroundName)
      ..writeByte(10)
      ..write(obj.alignment)
      ..writeByte(11)
      ..write(obj.level)
      ..writeByte(12)
      ..write(obj.experiencePoints)
      ..writeByte(13)
      ..write(obj.strength)
      ..writeByte(14)
      ..write(obj.dexterity)
      ..writeByte(15)
      ..write(obj.constitution)
      ..writeByte(16)
      ..write(obj.intelligence)
      ..writeByte(17)
      ..write(obj.wisdom)
      ..writeByte(18)
      ..write(obj.charisma)
      ..writeByte(19)
      ..write(obj.maxHP)
      ..writeByte(20)
      ..write(obj.currentHP)
      ..writeByte(21)
      ..write(obj.temporaryHP)
      ..writeByte(22)
      ..write(obj.armorClass)
      ..writeByte(23)
      ..write(obj.speed)
      ..writeByte(24)
      ..write(obj.initiative)
      ..writeByte(25)
      ..write(obj.hitDie)
      ..writeByte(26)
      ..write(obj.proficientSkills)
      ..writeByte(27)
      ..write(obj.savingThrowProfs)
      ..writeByte(28)
      ..write(obj.selectedSpells)
      ..writeByte(29)
      ..write(obj.preparedSpells)
      ..writeByte(30)
      ..write(obj.spellSlotsMax)
      ..writeByte(31)
      ..write(obj.spellSlotsUsed)
      ..writeByte(32)
      ..write(obj.personalityTraits)
      ..writeByte(33)
      ..write(obj.ideals)
      ..writeByte(34)
      ..write(obj.bonds)
      ..writeByte(35)
      ..write(obj.flaws)
      ..writeByte(36)
      ..write(obj.backstory)
      ..writeByte(37)
      ..write(obj.notes)
      ..writeByte(38)
      ..write(obj.equipment)
      ..writeByte(39)
      ..write(obj.copper)
      ..writeByte(40)
      ..write(obj.silver)
      ..writeByte(41)
      ..write(obj.electrum)
      ..writeByte(42)
      ..write(obj.gold)
      ..writeByte(43)
      ..write(obj.platinum)
      ..writeByte(44)
      ..write(obj.inspiration)
      ..writeByte(45)
      ..write(obj.deathSaveSuccesses)
      ..writeByte(46)
      ..write(obj.deathSaveFailures)
      ..writeByte(47)
      ..write(obj.avatarChoice)
      ..writeByte(48)
      ..write(obj.createdAt)
      ..writeByte(49)
      ..write(obj.updatedAt)
      ..writeByte(50)
      ..write(obj.spellcastingAbility)
      ..writeByte(51)
      ..write(obj.languages)
      ..writeByte(52)
      ..write(obj.proficiencies)
      ..writeByte(53)
      ..write(obj.attacks)
      ..writeByte(54)
      ..write(obj.concentrationSpell)
      ..writeByte(55)
      ..write(obj.backgroundSkillProfs)
      ..writeByte(56)
      ..write(obj.levelAdvancements)
      ..writeByte(57)
      ..write(obj.exhaustionLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
