import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ChoiceListEntry {
  final String id;
  final String name;
  final String summary;
  final String description;
  final String source;
  final String costLabel;
  final String prerequisite;
  final String roll;

  const ChoiceListEntry({
    required this.id,
    required this.name,
    required this.summary,
    required this.description,
    required this.source,
    this.costLabel = '',
    this.prerequisite = '',
    this.roll = '',
  });

  factory ChoiceListEntry.fromJson(Map<String, dynamic> json) {
    final id = _string(json['id']);
    final roll = _string(json['roll']);
    final description = _string(json['description']);
    return ChoiceListEntry(
      id: id,
      name: _string(json['name'], fallback: roll.isNotEmpty ? roll : id),
      summary: _string(json['summary'], fallback: _firstSentence(description)),
      description: description,
      source: _string(json['source']),
      costLabel:
          _string(json['costLabel'], fallback: _string(json['cost_label'])),
      prerequisite: _string(json['prerequisite']),
      roll: roll,
    );
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _firstSentence(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';

    final firstLine = text.split('\n').first.trim();
    final dotIndex = firstLine.indexOf('.');
    if (dotIndex < 0) return firstLine;
    return firstLine.substring(0, dotIndex + 1).trim();
  }
}

class ChoiceListsData {
  ChoiceListsData._();

  static const metamagicPath = 'assets/data/2024/metamagic_options.json';
  static const battleMasterManeuversPath =
      'assets/data/2024/battle_master_maneuvers.json';
  static const weaponMasteriesPath = 'assets/data/2024/weapon_masteries.json';
  static const eldritchInvocationsPath =
      'assets/data/2024/eldritch_invocations.json';
  static const wildMagicSurgesPath = 'assets/data/2024/wild_magic_surges.json';

  static List<ChoiceListEntry>? _metamagicOptions;
  static List<ChoiceListEntry>? _battleMasterManeuvers;
  static List<ChoiceListEntry>? _weaponMasteries;
  static List<ChoiceListEntry>? _eldritchInvocations;
  static List<ChoiceListEntry>? _wildMagicSurges;

  static List<ChoiceListEntry> get metamagicOptions {
    return _loaded(_metamagicOptions, 'metamagic options');
  }

  static List<ChoiceListEntry> get battleMasterManeuvers {
    return _loaded(_battleMasterManeuvers, 'Battle Master maneuvers');
  }

  static List<ChoiceListEntry> get weaponMasteries {
    return _loaded(_weaponMasteries, 'weapon masteries');
  }

  static List<ChoiceListEntry> get eldritchInvocations {
    return _loaded(_eldritchInvocations, 'eldritch invocations');
  }

  static List<ChoiceListEntry> get wildMagicSurges {
    return _loaded(_wildMagicSurges, 'wild magic surges');
  }

  static Future<void> load() async {
    if (_metamagicOptions != null) return;

    final results = await Future.wait([
      _loadList(metamagicPath),
      _loadList(battleMasterManeuversPath),
      _loadList(weaponMasteriesPath),
      _loadList(eldritchInvocationsPath),
      _loadList(wildMagicSurgesPath),
    ]);

    _metamagicOptions = results[0];
    _battleMasterManeuvers = results[1];
    _weaponMasteries = results[2];
    _eldritchInvocations = results[3];
    _wildMagicSurges = results[4];
  }

  static List<ChoiceListEntry> _loaded(
    List<ChoiceListEntry>? value,
    String label,
  ) {
    if (value == null) {
      throw StateError(
          'ChoiceListsData.load() must run before reading $label.');
    }
    return value;
  }

  static Future<List<ChoiceListEntry>> _loadList(String path) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map>()
        .map(
          (entry) => ChoiceListEntry.fromJson(
            Map<String, dynamic>.from(entry),
          ),
        )
        .where((entry) => entry.id.isNotEmpty)
        .toList(growable: false);
  }
}
