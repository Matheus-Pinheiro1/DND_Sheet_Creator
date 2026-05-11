import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/hive_constants.dart';
import '../data/models/custom_race_model.dart';
import '../data/models/custom_background_model.dart';
import '../data/models/custom_class_model.dart';

final customRacesProvider =
    StateNotifierProvider<CustomRacesNotifier, List<CustomRaceModel>>((ref) {
  return CustomRacesNotifier();
});

class CustomRacesNotifier extends StateNotifier<List<CustomRaceModel>> {
  Box<CustomRaceModel> get _box =>
      Hive.box<CustomRaceModel>(HiveConstants.customRaceBox);

  CustomRacesNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> save(CustomRaceModel race) async {
    await _box.put(race.id, race);
    _load();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _load();
  }
}

final customBackgroundsProvider =
    StateNotifierProvider<CustomBgNotifier, List<CustomBackgroundModel>>((ref) {
  return CustomBgNotifier();
});

class CustomBgNotifier extends StateNotifier<List<CustomBackgroundModel>> {
  Box<CustomBackgroundModel> get _box =>
      Hive.box<CustomBackgroundModel>(HiveConstants.customBgBox);

  CustomBgNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> save(CustomBackgroundModel bg) async {
    await _box.put(bg.id, bg);
    _load();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _load();
  }
}

final customClassesProvider =
    StateNotifierProvider<CustomClassesNotifier, List<CustomClassModel>>((ref) {
  return CustomClassesNotifier();
});

class CustomClassesNotifier extends StateNotifier<List<CustomClassModel>> {
  Box<CustomClassModel> get _box =>
      Hive.box<CustomClassModel>(HiveConstants.customClassBox);

  CustomClassesNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  Future<void> save(CustomClassModel cls) async {
    await _box.put(cls.id, cls);
    _load();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _load();
  }
}
