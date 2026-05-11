import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/feat_model.dart';

class FeatsData {
  FeatsData._();

  static const assetPath = 'assets/data/2024/feats.json';
  static List<FeatModel>? _catalog;

  static List<FeatModel> get catalog {
    final loaded = _catalog;
    if (loaded == null) {
      throw StateError('FeatsData.load() must run before reading feats.');
    }
    return loaded;
  }

  static Future<void> load() async {
    if (_catalog != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    _catalog = list
        .whereType<Map>()
        .map((entry) => FeatModel.fromJson(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }
}

List<FeatModel> get kFeatCatalog => FeatsData.catalog;
