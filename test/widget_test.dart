import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dnd_character_sheet/app.dart';
import 'package:dnd_character_sheet/core/constants/hive_constants.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/data/models/attack_model.dart';
import 'package:dnd_character_sheet/data/models/custom_race_model.dart';
import 'package:dnd_character_sheet/data/models/custom_background_model.dart';
import 'package:dnd_character_sheet/data/models/custom_class_model.dart';
import 'package:dnd_character_sheet/data/local/local_data_loader.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LocalDataLoader.loadAll();
    await Hive.initFlutter('test_hive');

    if (!Hive.isAdapterRegistered(HiveConstants.characterTypeId)) {
      Hive.registerAdapter(CharacterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.attackTypeId)) {
      Hive.registerAdapter(AttackModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.customRaceTypeId)) {
      Hive.registerAdapter(CustomRaceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.customBgTypeId)) {
      Hive.registerAdapter(CustomBackgroundModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.customClassTypeId)) {
      Hive.registerAdapter(CustomClassModelAdapter());
    }

    await Future.wait([
      Hive.openBox<CharacterModel>(HiveConstants.characterBox),
      Hive.openBox<String>(HiveConstants.spellCacheBox),
      Hive.openBox<CustomRaceModel>(HiveConstants.customRaceBox),
      Hive.openBox<CustomBackgroundModel>(HiveConstants.customBgBox),
      Hive.openBox<CustomClassModel>(HiveConstants.customClassBox),
      Hive.openBox<String>(HiveConstants.encounterBox),
    ]);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(HiveConstants.characterBox);
    await Hive.deleteBoxFromDisk(HiveConstants.spellCacheBox);
    await Hive.deleteBoxFromDisk(HiveConstants.customRaceBox);
    await Hive.deleteBoxFromDisk(HiveConstants.customBgBox);
    await Hive.deleteBoxFromDisk(HiveConstants.customClassBox);
    await Hive.deleteBoxFromDisk(HiveConstants.encounterBox);
    await Hive.close();
  });

  testWidgets('App inicia e mostra a home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('D&D Character Sheet'), findsAny);
  });
}
