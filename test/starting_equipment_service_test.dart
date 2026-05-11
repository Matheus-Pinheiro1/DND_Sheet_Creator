import 'package:dnd_character_sheet/data/local/equipment_options_data.dart';
import 'package:dnd_character_sheet/data/remote/background_dto.dart';
import 'package:dnd_character_sheet/data/services/starting_equipment_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EquipmentOptionsData.load();
  });

  group('StartingEquipmentService', () {
    test('parses structured equipment options', () {
      final options = StartingEquipmentService.parseOptions([
        {
          'id': 'A',
          'gold': 15,
          'items': [
            {'id': 'greataxe', 'name': 'Greataxe'},
            {'id': 'handaxe', 'name': 'Handaxe', 'quantity': 4},
          ],
        },
      ]);

      expect(options.single.id, 'A');
      expect(options.single.gold, 15);
      expect(options.single.items, ['Greataxe', '4 Handaxes']);
    });

    test('keeps parsing legacy text equipment options', () {
      final options = StartingEquipmentService.parseOptions([
        "A: Chain Shirt, Shield, Mace, Holy Symbol, Priest's Pack, 7 GP",
      ]);

      expect(options.single.id, 'A');
      expect(options.single.gold, 7);
      expect(options.single.items, [
        'Chain Shirt',
        'Shield',
        'Mace',
        'Holy Symbol',
        "Priest's Pack",
      ]);
    });

    test('builds class and background selections from structured data', () {
      final selection = StartingEquipmentService.buildSelection(
        className: 'fighter',
        classEquipmentChoiceId: 'A',
        backgroundOptions: [
          {
            'id': 'B',
            'gold': 50,
            'items': [],
          },
        ],
        backgroundEquipmentChoiceId: 'B',
      );

      expect(selection.gold, 54);
      expect(selection.items, contains('Chain Mail'));
      expect(selection.items, contains('Greatsword'));
      expect(selection.items, contains('8 Javelins'));
    });

    test('BackgroundDto keeps structured equipment options parseable', () {
      final background = BackgroundDto.fromJson({
        'index': 'test',
        'name': 'Test',
        'starting_proficiencies': const [],
        'equipment_options': [
          {
            'id': 'A',
            'gold': 8,
            'items': [
              {'id': 'dagger', 'name': 'Dagger', 'quantity': 2},
            ],
          },
        ],
      });

      final options = StartingEquipmentService.parseOptions(
        background.equipmentOptions,
      );

      expect(options.single.gold, 8);
      expect(options.single.items, ['2 Daggers']);
    });
  });
}
