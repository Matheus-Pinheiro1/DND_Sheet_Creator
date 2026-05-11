import 'package:hive/hive.dart';
import '../../core/constants/hive_constants.dart';

part 'attack_model.g.dart';

@HiveType(typeId: HiveConstants.attackTypeId)
class AttackModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String attackBonus;
  @HiveField(2)
  final String damageDice;
  @HiveField(3)
  final String damageType;
  @HiveField(4)
  final String range;
  @HiveField(5)
  final String properties;
  @HiveField(6)
  final bool isMagic;

  const AttackModel({
    required this.name,
    this.attackBonus = '+0',
    this.damageDice = '1d4',
    this.damageType = 'Slashing',
    this.range = '5 ft',
    this.properties = '',
    this.isMagic = false,
  });

  AttackModel copyWith({
    String? name,
    String? attackBonus,
    String? damageDice,
    String? damageType,
    String? range,
    String? properties,
    bool? isMagic,
  }) {
    return AttackModel(
      name: name ?? this.name,
      attackBonus: attackBonus ?? this.attackBonus,
      damageDice: damageDice ?? this.damageDice,
      damageType: damageType ?? this.damageType,
      range: range ?? this.range,
      properties: properties ?? this.properties,
      isMagic: isMagic ?? this.isMagic,
    );
  }
}
