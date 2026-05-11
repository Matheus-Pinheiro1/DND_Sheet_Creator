// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/hive_constants.dart';
import 'data/models/attack_model.dart';
import 'data/models/character_model.dart';
import 'data/models/custom_background_model.dart';
import 'data/models/custom_class_model.dart';
import 'data/models/custom_race_model.dart';
import 'data/local/local_data_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDataLoader.loadAll();
  await _startLocalStorage();
  runApp(const ProviderScope(child: App()));
}

Future<void> _startLocalStorage() async {
  await Hive.initFlutter();
  _registerHiveAdapters();
  await _openHiveBoxes();
}

void _registerHiveAdapters() {
  Hive.registerAdapter(CharacterModelAdapter());
  Hive.registerAdapter(AttackModelAdapter());
  Hive.registerAdapter(CustomRaceModelAdapter());
  Hive.registerAdapter(CustomBackgroundModelAdapter());
  Hive.registerAdapter(CustomClassModelAdapter());
}

Future<void> _openHiveBoxes() {
  return Future.wait([
    Hive.openBox<CharacterModel>(HiveConstants.characterBox),
    Hive.openBox<String>(HiveConstants.spellCacheBox),
    Hive.openBox<CustomRaceModel>(HiveConstants.customRaceBox),
    Hive.openBox<CustomBackgroundModel>(HiveConstants.customBgBox),
    Hive.openBox<CustomClassModel>(HiveConstants.customClassBox),
    Hive.openBox<String>(HiveConstants.encounterBox),
  ]);
}
