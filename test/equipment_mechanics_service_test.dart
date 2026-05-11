import 'package:dnd_character_sheet/data/local/armor_data.dart';
import 'package:dnd_character_sheet/data/local/weapons_data.dart';
import 'package:dnd_character_sheet/data/models/attack_model.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/data/services/equipment_mechanics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ArmorData.load();
    await WeaponsData.load();
  });

  group('EquipmentMechanicsService', () {
    test('shield increases unarmored AC by 2', () {
      final ac = EquipmentMechanicsService.calculateArmorClass(
        className: 'cleric',
        subclass: '',
        level: 1,
        dexterity: 14,
        constitution: 10,
        wisdom: 10,
        charisma: 10,
        equipment: const ['Shield'],
      );

      expect(ac, 14);
    });

    test('armor and shield use the equipment AC formula', () {
      final ac = EquipmentMechanicsService.calculateArmorClass(
        className: 'cleric',
        subclass: '',
        level: 1,
        dexterity: 14,
        constitution: 10,
        wisdom: 10,
        charisma: 10,
        equipment: const ['Chain Mail', 'Shield'],
      );

      expect(ac, 18);
    });

    test('weapons from equipment become attacks', () {
      final character = CharacterModel(
        id: 'test',
        name: 'Fighter',
        className: 'fighter',
        level: 1,
        strength: 16,
        dexterity: 10,
        proficiencies: const ['Martial weapons'],
      );

      final attacks = EquipmentMechanicsService.weaponAttacksFromEquipment(
        equipment: const ['Greatsword', '4 Handaxes'],
        character: character,
      );

      expect(attacks.map((attack) => attack.name), ['Greatsword', 'Handaxe']);
      expect(attacks.first.attackBonus, '+5');
      expect(attacks.first.damageDice, '2d6');
    });

    test('removed equipment weapons remove their generated attacks', () {
      const existingAttacks = [
        AttackModel(name: 'Greatsword'),
        AttackModel(name: 'Second Wind', isMagic: true),
      ];

      final attacks =
          EquipmentMechanicsService.removeMissingEquipmentWeaponAttacks(
        existingAttacks: existingAttacks,
        previousEquipment: const ['Greatsword'],
        nextEquipment: const [],
      );

      expect(attacks.map((attack) => attack.name), ['Second Wind']);
    });
  });
}
