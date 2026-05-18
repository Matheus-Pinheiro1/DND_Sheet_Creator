import '../../core/utils/dice_calculator.dart';
import '../../core/utils/weapon_bonus_calculator.dart';
import '../local/armor_data.dart';
import '../local/weapons_data.dart';
import '../models/attack_model.dart';
import '../models/character_model.dart';
import 'bard_choice_service.dart';
import 'equipment_entry_service.dart';
import 'monk_choice_service.dart';

class EquipmentMechanicsService {
  EquipmentMechanicsService._();

  static int calculateArmorClass({
    required String className,
    required String subclass,
    required int level,
    required int dexterity,
    required int constitution,
    required int wisdom,
    required int charisma,
    required List<String> equipment,
  }) {
    final activeEquipment = EquipmentEntryService.equippedEntries(equipment);
    final dexMod = DiceCalculator.getModifier(dexterity);
    final shieldBonus = hasShield(activeEquipment) ? 2 : 0;
    final armor = _bestArmor(activeEquipment, dexMod: dexMod);

    if (armor != null) {
      return armor.baseAc + armor.dexBonus(dexMod) + shieldBonus;
    }

    if (MonkChoiceService.isMonk(className: className) && shieldBonus == 0) {
      return 10 + dexMod + DiceCalculator.getModifier(wisdom);
    }

    if (className == 'barbarian') {
      return 10 +
          dexMod +
          DiceCalculator.getModifier(constitution) +
          shieldBonus;
    }

    if (BardChoiceService.isDance(
          className: className,
          subclass: subclass,
          level: level,
        ) &&
        shieldBonus == 0) {
      return 10 + dexMod + DiceCalculator.getModifier(charisma);
    }

    return 10 + dexMod + shieldBonus;
  }

  static bool hasShield(List<String> equipment) {
    return EquipmentEntryService.equippedEntries(equipment).any(isShieldEntry);
  }

  static bool affectsArmorClass(List<String> equipment) {
    final activeEquipment = EquipmentEntryService.equippedEntries(equipment);
    return hasShield(activeEquipment) || _bestArmor(activeEquipment) != null;
  }

  static String armorClassSourceKey(List<String> equipment) {
    final activeEquipment = EquipmentEntryService.equippedEntries(equipment);
    final armor = armorFromEquipmentEntries(activeEquipment)?.name ??
        _bestArmor(activeEquipment)?.name ??
        '';
    final shield = hasShield(activeEquipment) ? 'shield' : '';
    return '$armor|$shield';
  }

  static DndArmor? armorFromEquipmentEntry(String entry) {
    final candidates = _candidateNames(entry);

    for (final armor in kDndArmors) {
      final names = {
        _normalize(armor.id),
        _normalize(armor.name),
        ...armor.aliases.map(_normalize),
      };
      if (candidates.any(names.contains)) {
        return armor;
      }
    }

    return null;
  }

  static DndArmor? armorFromEquipmentEntries(List<String> equipment) {
    DndArmor? best;

    for (final entry in EquipmentEntryService.equippedEntries(equipment)) {
      final armor = armorFromEquipmentEntry(entry);
      if (armor == null || armor.isShield) continue;
      if (best == null || armor.baseAc > best.baseAc) {
        best = armor;
      }
    }

    return best;
  }

  static bool isArmorEntry(String entry) {
    final armor = armorFromEquipmentEntry(entry);
    return armor != null && !armor.isShield;
  }

  static bool isShieldEntry(String entry) {
    return armorFromEquipmentEntry(entry)?.isShield == true ||
        _candidateNames(entry).contains('shield');
  }

  static _ArmorRule? _bestArmor(List<String> equipment, {int? dexMod}) {
    _ArmorRule? best;

    for (final entry in equipment) {
      final candidates = _candidateNames(entry);
      for (final armor in _armorRules) {
        if (!candidates.any(armor.matches)) continue;
        if (best == null || _isBetterArmor(armor, best, dexMod)) {
          best = armor;
        }
      }
    }

    return best;
  }

  static bool _isBetterArmor(
    _ArmorRule armor,
    _ArmorRule best,
    int? dexMod,
  ) {
    if (dexMod == null) return armor.baseAc > best.baseAc;
    final armorAc = armor.baseAc + armor.dexBonus(dexMod);
    final bestAc = best.baseAc + best.dexBonus(dexMod);
    if (armorAc != bestAc) return armorAc > bestAc;
    return armor.baseAc > best.baseAc;
  }

  static List<AttackModel> weaponAttacksFromEquipment({
    required List<String> equipment,
    required CharacterModel character,
  }) {
    final attacks = <AttackModel>[];
    final added = <String>{};

    for (final entry in EquipmentEntryService.equippedEntries(equipment)) {
      final weapon = weaponFromEquipmentEntry(entry);
      if (weapon == null) continue;

      final key = _normalize(weapon.name);
      if (!added.add(key)) continue;

      attacks.add(
        AttackModel(
          name: weapon.name,
          attackBonus: WeaponBonusCalculator.calculateWeaponBonus(
            weapon,
            character,
          ),
          damageDice: WeaponBonusCalculator.calculateWeaponDamageDice(
            weapon,
            character,
          ),
          damageType: WeaponBonusCalculator.calculateWeaponDamageType(
            weapon,
            character,
          ),
          range: weapon.range,
          properties: weapon.properties,
        ),
      );
    }

    return attacks;
  }

  static DndWeapon? weaponFromEquipmentEntry(String entry) {
    final candidates = _candidateNames(entry);

    for (final weapon in kDndWeapons) {
      final weaponName = _normalize(weapon.name);
      final pluralName = '${weaponName}s';
      if (candidates.contains(weaponName) || candidates.contains(pluralName)) {
        return weapon;
      }
    }

    return null;
  }

  static List<AttackModel> mergeEquipmentAttacks({
    required List<AttackModel> existingAttacks,
    required List<AttackModel> equipmentAttacks,
  }) {
    final merged = List<AttackModel>.from(existingAttacks);

    for (final equipmentAttack in equipmentAttacks) {
      final index = merged.indexWhere(
        (attack) =>
            !attack.isMagic &&
            _normalize(attack.name) == _normalize(equipmentAttack.name),
      );

      if (index >= 0) {
        merged[index] = merged[index].copyWith(
          attackBonus: equipmentAttack.attackBonus,
          damageDice: equipmentAttack.damageDice,
          damageType: equipmentAttack.damageType,
          range: equipmentAttack.range,
          properties: equipmentAttack.properties,
        );
      } else {
        merged.add(equipmentAttack);
      }
    }

    return merged;
  }

  static List<AttackModel> removeMissingEquipmentWeaponAttacks({
    required List<AttackModel> existingAttacks,
    required List<String> previousEquipment,
    required List<String> nextEquipment,
  }) {
    final previousWeapons = _weaponNameKeysFromEquipment(previousEquipment);
    final nextWeapons = _weaponNameKeysFromEquipment(nextEquipment);
    final removedWeapons = previousWeapons.difference(nextWeapons);
    if (removedWeapons.isEmpty) return existingAttacks;

    return existingAttacks
        .where(
          (attack) =>
              attack.isMagic ||
              !removedWeapons.contains(
                _normalize(attack.name),
              ),
        )
        .toList(growable: false);
  }

  static CharacterModel applyEquipmentMechanics(CharacterModel character) {
    final armorClass = calculateArmorClass(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
      dexterity: character.dexterity,
      constitution: character.constitution,
      wisdom: character.wisdom,
      charisma: character.charisma,
      equipment: character.equipment,
    );
    final attacks = mergeEquipmentAttacks(
      existingAttacks: character.attacks,
      equipmentAttacks: weaponAttacksFromEquipment(
        equipment: character.equipment,
        character: character,
      ),
    );

    return character.copyWith(armorClass: armorClass, attacks: attacks);
  }

  static List<String> _candidateNames(String entry) {
    final rawName = EquipmentEntryService.parse(entry).name;
    final parenthetical = RegExp(r'\(([^)]+)\)')
        .allMatches(rawName)
        .map((match) => _normalize(match.group(1) ?? ''))
        .where((value) => value.isNotEmpty);
    final baseName = _normalize(
      rawName.replaceAll(RegExp(r'\([^)]*\)'), ' '),
    );
    final withoutQuantity = _normalize(
      baseName.replaceFirst(RegExp(r'^\d+\s+'), ''),
    );

    return {
      baseName,
      withoutQuantity,
      ...parenthetical,
    }.where((value) => value.isNotEmpty).toList(growable: false);
  }

  static Set<String> _weaponNameKeysFromEquipment(List<String> equipment) {
    return EquipmentEntryService.equippedEntries(equipment)
        .map(weaponFromEquipmentEntry)
        .nonNulls
        .map((weapon) => _normalize(weapon.name))
        .toSet();
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const List<_ArmorRule> _armorRules = [
    _ArmorRule(name: 'padded', baseAc: 11, dexMode: _ArmorDexMode.full),
    _ArmorRule(name: 'leather', baseAc: 11, dexMode: _ArmorDexMode.full),
    _ArmorRule(
      name: 'studded leather',
      baseAc: 12,
      dexMode: _ArmorDexMode.full,
    ),
    _ArmorRule(name: 'hide', baseAc: 12, dexMode: _ArmorDexMode.maxTwo),
    _ArmorRule(
      name: 'chain shirt',
      baseAc: 13,
      dexMode: _ArmorDexMode.maxTwo,
    ),
    _ArmorRule(name: 'scale mail', baseAc: 14, dexMode: _ArmorDexMode.maxTwo),
    _ArmorRule(name: 'breastplate', baseAc: 14, dexMode: _ArmorDexMode.maxTwo),
    _ArmorRule(name: 'half plate', baseAc: 15, dexMode: _ArmorDexMode.maxTwo),
    _ArmorRule(name: 'ring mail', baseAc: 14, dexMode: _ArmorDexMode.none),
    _ArmorRule(name: 'chain mail', baseAc: 16, dexMode: _ArmorDexMode.none),
    _ArmorRule(name: 'splint', baseAc: 17, dexMode: _ArmorDexMode.none),
    _ArmorRule(name: 'plate', baseAc: 18, dexMode: _ArmorDexMode.none),
  ];
}

enum _ArmorDexMode { full, maxTwo, none }

class _ArmorRule {
  final String name;
  final int baseAc;
  final _ArmorDexMode dexMode;

  const _ArmorRule({
    required this.name,
    required this.baseAc,
    required this.dexMode,
  });

  int dexBonus(int dexMod) {
    return switch (dexMode) {
      _ArmorDexMode.full => dexMod,
      _ArmorDexMode.maxTwo => dexMod.clamp(-999, 2).toInt(),
      _ArmorDexMode.none => 0,
    };
  }

  bool matches(String candidate) {
    final normalized = name;
    return candidate == normalized || candidate == '$normalized armor';
  }
}
