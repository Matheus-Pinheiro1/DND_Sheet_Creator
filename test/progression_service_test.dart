import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_character_sheet/data/local/progression_data.dart';
import 'package:dnd_character_sheet/data/services/fighter_choice_service.dart';
import 'package:dnd_character_sheet/data/services/progression_service.dart';
import 'package:dnd_character_sheet/data/services/rogue_choice_service.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ProgressionData.load();
  });

  group('ProgressionService 2024 spell progression', () {
    test('sorcerer prepared spell counts follow the 2024 table', () {
      expect(_prepared('sorcerer', 1), 2);
      expect(_prepared('sorcerer', 2), 4);
      expect(_prepared('sorcerer', 3), 6);
      expect(_prepared('sorcerer', 8), 12);
      expect(_prepared('sorcerer', 20), 22);
    });

    test('full prepared casters share the full caster prepared table', () {
      for (final className in ['bard', 'cleric', 'druid', 'wizard']) {
        expect(_prepared(className, 1), 4, reason: className);
        expect(_prepared(className, 8), 12, reason: className);
        expect(_prepared(className, 20), 22, reason: className);
      }
    });

    test('half casters use the 2024 prepared table from level 1', () {
      for (final className in ['paladin', 'ranger']) {
        expect(_prepared(className, 1), 2, reason: className);
        expect(_prepared(className, 8), 7, reason: className);
        expect(_prepared(className, 20), 15, reason: className);
      }
    });

    test('warlock prepared spell counts stay separate from full casters', () {
      expect(_prepared('warlock', 1), 2);
      expect(_prepared('warlock', 8), 9);
      expect(_prepared('warlock', 20), 15);
    });

    test('spell slots are read from progression data', () {
      expect(
        ProgressionService.getSpellSlotsListFor(
          className: 'sorcerer',
          level: 8,
        ).take(4),
        [4, 3, 3, 2],
      );
      expect(
        ProgressionService.getSpellSlotsListFor(
          className: 'warlock',
          level: 8,
        ).take(5),
        [0, 0, 0, 2, 0],
      );
    });
  });

  group('ProgressionService advancement and class bonuses', () {
    test('advancement levels come from progression data', () {
      expect(
        ProgressionService.getAdvancementLevels('fighter'),
        [4, 6, 8, 12, 14, 16, 19],
      );
      expect(
        ProgressionService.getAdvancementLevels('rogue'),
        [4, 8, 10, 12, 16, 19],
      );
      expect(
        ProgressionService.getAdvancementLevels('wizard'),
        [4, 8, 12, 16, 19],
      );
      expect(
        ProgressionService.getAdvancementLevels('custom_class_123'),
        [4, 8, 12, 16, 19],
      );
    });

    test('simple level bonuses come from progression data', () {
      expect(ProgressionService.getMonkMartialArtsDie(4), '1d6');
      expect(ProgressionService.getMonkMartialArtsDie(5), '1d8');
      expect(ProgressionService.getMonkUnarmoredMovementBonus(13), 20);
      expect(ProgressionService.getRangerRovingSpeedBonus(5), 0);
      expect(ProgressionService.getRangerRovingSpeedBonus(6), 10);
      expect(ProgressionService.getBarbarianFastMovementBonus(4), 0);
      expect(ProgressionService.getBarbarianFastMovementBonus(5), 10);
    });
  });

  group('Subclass caster progression tables', () {
    test('eldritch knight and arcane trickster stay aligned', () {
      for (final level in [3, 4, 7, 8, 10, 13, 16, 19, 20]) {
        expect(
          FighterChoiceService.eldritchKnightPreparedSpellCount(level),
          RogueChoiceService.arcaneTricksterPreparedSpellCount(level),
          reason: 'prepared spells at level $level',
        );
        expect(
          FighterChoiceService.eldritchKnightSpellSlots(level),
          RogueChoiceService.arcaneTricksterSpellSlots(level),
          reason: 'spell slots at level $level',
        );
      }
    });
  });
}

int _prepared(String className, int level) {
  return ProgressionService.getSpellLimitsFor(
    className: className,
    level: level,
    spellcastingModifier: 0,
  ).maxLeveledSpells;
}
