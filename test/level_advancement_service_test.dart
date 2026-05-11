import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_character_sheet/data/services/level_advancement_service.dart';

void main() {
  group('LevelAdvancementService entry parsing', () {
    test('origin entries are not class level entries', () {
      expect(LevelAdvancementService.isOriginEntry('origin_feat:lucky'), isTrue);
      expect(LevelAdvancementService.isOriginEntry('origin_asi:str+1,wis+2'), isTrue);
      expect(
        LevelAdvancementService.isClassLevelEntry('origin_feat:lucky'),
        isFalse,
      );
      expect(
        LevelAdvancementService.isClassLevelEntry('origin_asi:str+1,wis+2'),
        isFalse,
      );
    });

    test('class ASI and feat entries are class level entries', () {
      expect(
        LevelAdvancementService.isClassLevelEntry('level:4:asi:str+2'),
        isTrue,
      );
      expect(
        LevelAdvancementService.isClassLevelEntry('level:8:feat:war-caster:int'),
        isTrue,
      );
      expect(LevelAdvancementService.levelFromEntry('level:12:asi:dex+2'), 12);
    });

    test('legacy entries remain supported', () {
      expect(LevelAdvancementService.isClassLevelEntry('asi:str+2'), isTrue);
      expect(LevelAdvancementService.isClassLevelEntry('feat:alert:dex'), isTrue);
      expect(LevelAdvancementService.levelFromEntry('asi:str+2'), isNull);
    });

    test('new encoders store the exact class level', () {
      expect(
        LevelAdvancementService.encodeAsi(level: 4, rawBonuses: 'str+2'),
        'level:4:asi:str+2',
      );
      expect(
        LevelAdvancementService.encodeFeat(
          level: 8,
          featId: 'war-caster',
          ability: 'int',
        ),
        'level:8:feat:war-caster:int',
      );
    });

    test('normal ASI cap remains 20 before epic levels', () {
      expect(
        LevelAdvancementService.canIncreaseAbility(
          currentScore: 18,
          increase: 2,
          advancementLevel: 4,
        ),
        isTrue,
      );
      expect(
        LevelAdvancementService.canIncreaseAbility(
          currentScore: 19,
          increase: 2,
          advancementLevel: 4,
        ),
        isFalse,
      );
    });
  });
}
