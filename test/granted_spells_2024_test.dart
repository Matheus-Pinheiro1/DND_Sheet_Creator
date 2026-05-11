import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_character_sheet/data/local/granted_spells_2024.dart';
import 'package:dnd_character_sheet/data/services/fighter_choice_service.dart';
import 'package:dnd_character_sheet/data/services/rogue_choice_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GrantedSpells2024Data.load();
  });

  group('Granted spell gating', () {
    test('Light Domain Cleric level 4 does not receive Fireball', () {
      final spells = _grantedSpellIds(
        subclass: 'cleric-light',
        raceValue: 'elf::lineage::high-elf',
        level: 4,
      );

      expect(spells, contains('burning-hands'));
      expect(spells, contains('faerie-fire'));
      expect(spells, contains('detect-magic'));
      expect(spells, isNot(contains('fireball')));
      expect(spells, isNot(contains('misty-step')));
    });

    test('Light Domain Cleric receives Fireball when the level gate is met',
        () {
      final spells = _grantedSpellIds(
        subclass: 'cleric-light',
        level: 5,
      );

      expect(spells, contains('fireball'));
    });

    test('Oath of Vengeance gates higher oath spells', () {
      final level4 = _grantedSpellIds(
        subclass: 'paladin-vengeance',
        level: 4,
      );

      expect(level4, contains('bane'));
      expect(level4, contains('hunter-s-mark'));
      expect(level4, isNot(contains('haste')));

      final level9 = _grantedSpellIds(
        subclass: 'paladin-vengeance',
        level: 9,
      );

      expect(level9, contains('haste'));
    });

    test('High Elf gates Misty Step at level 5', () {
      final level4 = _grantedSpellIds(
        raceValue: 'elf::lineage::high-elf',
        level: 4,
      );

      expect(level4, contains('detect-magic'));
      expect(level4, isNot(contains('misty-step')));

      final level5 = _grantedSpellIds(
        raceValue: 'elf::lineage::high-elf',
        level: 5,
      );

      expect(level5, contains('misty-step'));
    });

    test('Infernal Tiefling gates Darkness at level 5', () {
      final level4 = _grantedSpellIds(
        raceValue: 'tiefling::fiendish-legacy::infernal',
        level: 4,
      );

      expect(level4, contains('fire-bolt'));
      expect(level4, contains('hellish-rebuke'));
      expect(level4, isNot(contains('darkness')));

      final level5 = _grantedSpellIds(
        raceValue: 'tiefling::fiendish-legacy::infernal',
        level: 5,
      );

      expect(level5, contains('darkness'));
    });
  });

  group('Martial spellcasting subclasses', () {
    test('Eldritch Knight unlocks spellcasting only at Fighter level 3+', () {
      expect(
        FighterChoiceService.isEldritchKnight(
          className: 'fighter',
          subclass: FighterChoiceService.eldritchKnightSubclass,
          level: 2,
        ),
        isFalse,
      );
      expect(FighterChoiceService.eldritchKnightMaxSpellLevel(2), 0);

      expect(
        FighterChoiceService.isEldritchKnight(
          className: 'fighter',
          subclass: FighterChoiceService.eldritchKnightSubclass,
          level: 3,
        ),
        isTrue,
      );
      expect(FighterChoiceService.eldritchKnightMaxSpellLevel(3), 1);
    });

    test('Arcane Trickster unlocks spellcasting only at Rogue level 3+', () {
      expect(
        RogueChoiceService.isArcaneTrickster(
          className: 'rogue',
          subclass: RogueChoiceService.arcaneTricksterSubclass,
          level: 2,
        ),
        isFalse,
      );
      expect(RogueChoiceService.arcaneTricksterMaxSpellLevel(2), 0);

      expect(
        RogueChoiceService.isArcaneTrickster(
          className: 'rogue',
          subclass: RogueChoiceService.arcaneTricksterSubclass,
          level: 3,
        ),
        isTrue,
      );
      expect(RogueChoiceService.arcaneTricksterMaxSpellLevel(3), 1);
    });
  });
}

Set<String> _grantedSpellIds({
  String subclass = '',
  String raceValue = '',
  required int level,
}) {
  return buildGrantedSpellEntries(
    className: '',
    subclass: subclass,
    raceValue: raceValue,
    level: level,
  ).map((entry) => entry.spellIndex).toSet();
}
