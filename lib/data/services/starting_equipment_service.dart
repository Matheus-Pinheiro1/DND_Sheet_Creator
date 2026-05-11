import '../local/equipment_options_data.dart';

class StartingEquipmentItem {
  final String id;
  final String name;
  final int quantity;
  final String description;
  final String displayName;

  const StartingEquipmentItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.description = '',
    this.displayName = '',
  });

  String get label {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    if (quantity <= 1) return name;
    return '$quantity ${_pluralize(name)}';
  }

  static StartingEquipmentItem fromJson(Map<String, dynamic> json) {
    final name = _string(json['name']);
    final quantity = _int(json['quantity'], fallback: 1);
    return StartingEquipmentItem(
      id: _string(json['id'], fallback: _slug(name)),
      name: name,
      quantity: quantity <= 0 ? 1 : quantity,
      description: _string(json['description']),
      displayName: _string(json['display_name']),
    );
  }

  static StartingEquipmentItem fromText(String text) {
    final trimmed = text.trim();
    final quantityMatch = RegExp(r'^(\d+)\s+(.+)$').firstMatch(trimmed);
    final quantity = int.tryParse(quantityMatch?.group(1) ?? '') ?? 1;
    final name = quantityMatch?.group(2)?.trim() ?? trimmed;
    return StartingEquipmentItem(
      id: _slug(name),
      name: name,
      quantity: quantity,
      displayName: trimmed,
    );
  }

  static String _pluralize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('s')) return trimmed;
    if (trimmed.endsWith('x') ||
        trimmed.endsWith('ch') ||
        trimmed.endsWith('sh')) {
      return '${trimmed}es';
    }
    if (trimmed.endsWith('y') && trimmed.length > 1) {
      return '${trimmed.substring(0, trimmed.length - 1)}ies';
    }
    return '${trimmed}s';
  }

  static String _slug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _int(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class StartingEquipmentOption {
  final String id;
  final String label;
  final String text;
  final List<StartingEquipmentItem> equipment;
  final int gold;

  const StartingEquipmentOption({
    required this.id,
    required this.label,
    required this.text,
    required this.equipment,
    required this.gold,
  });

  List<String> get items {
    return equipment.map((item) => item.label).toList(growable: false);
  }
}

class StartingEquipmentSelection {
  final List<String> items;
  final int gold;

  const StartingEquipmentSelection({
    required this.items,
    required this.gold,
  });
}

class StartingEquipmentService {
  StartingEquipmentService._();

  static const classEquipmentEntryPrefix =
      'class_choice:starting_equipment_class:';
  static const backgroundEquipmentEntryPrefix =
      'class_choice:starting_equipment_background:';

  static bool isStartingEquipmentEntry(String entry) {
    return entry.startsWith(classEquipmentEntryPrefix) ||
        entry.startsWith(backgroundEquipmentEntryPrefix);
  }

  static List<dynamic> classOptionTexts(String className) {
    return EquipmentOptionsData.classOptionsFor(className);
  }

  static List<StartingEquipmentOption> parseOptions(List<dynamic> options) {
    return [
      for (var i = 0; i < options.length; i++)
        _parseOption(options[i], fallbackId: _fallbackId(i)),
    ];
  }

  static StartingEquipmentOption? optionById(
    List<StartingEquipmentOption> options,
    String id,
  ) {
    final normalized = id.trim().toUpperCase();
    for (final option in options) {
      if (option.id == normalized) return option;
    }
    return null;
  }

  static String selectedClassEquipmentId(List<String> entries) {
    return _selectedId(entries, classEquipmentEntryPrefix);
  }

  static String selectedBackgroundEquipmentId(List<String> entries) {
    return _selectedId(entries, backgroundEquipmentEntryPrefix);
  }

  static StartingEquipmentSelection buildSelection({
    required String className,
    required String classEquipmentChoiceId,
    required List<dynamic> backgroundOptions,
    required String backgroundEquipmentChoiceId,
  }) {
    final classOption = optionById(
      parseOptions(classOptionTexts(className)),
      classEquipmentChoiceId,
    );
    final backgroundOption = optionById(
      parseOptions(backgroundOptions),
      backgroundEquipmentChoiceId,
    );

    final items = <String>[
      if (classOption != null) ...classOption.items,
      if (backgroundOption != null) ...backgroundOption.items,
    ];
    final gold = (classOption?.gold ?? 0) + (backgroundOption?.gold ?? 0);

    return StartingEquipmentSelection(items: items, gold: gold);
  }

  static StartingEquipmentOption _parseOption(
    dynamic raw, {
    required String fallbackId,
  }) {
    if (raw is Map) {
      return _parseStructuredOption(
        Map<String, dynamic>.from(raw),
        fallbackId: fallbackId,
      );
    }

    return _parseTextOption(raw.toString(), fallbackId: fallbackId);
  }

  static StartingEquipmentOption _parseStructuredOption(
    Map<String, dynamic> raw, {
    required String fallbackId,
  }) {
    final id = (raw['id']?.toString().trim().isEmpty ?? true)
        ? fallbackId
        : raw['id'].toString().trim().toUpperCase();
    final gold = _int(raw['gold'], fallback: 0);
    final equipment = (raw['items'] as List<dynamic>? ?? const [])
        .map(_parseStructuredItem)
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
    final text = raw['text']?.toString().trim();

    return StartingEquipmentOption(
      id: id,
      label: raw['label']?.toString().trim().isNotEmpty == true
          ? raw['label'].toString().trim()
          : 'Option $id',
      text: text == null || text.isEmpty
          ? _buildOptionText(equipment: equipment, gold: gold)
          : text,
      equipment: equipment,
      gold: gold,
    );
  }

  static StartingEquipmentItem _parseStructuredItem(dynamic raw) {
    if (raw is Map) {
      return StartingEquipmentItem.fromJson(Map<String, dynamic>.from(raw));
    }
    return StartingEquipmentItem.fromText(raw.toString());
  }

  static StartingEquipmentOption _parseTextOption(
    String raw, {
    required String fallbackId,
  }) {
    final match = RegExp(r'^\s*([A-Z])\s*:\s*(.*)$').firstMatch(raw);
    final id = (match?.group(1) ?? fallbackId).toUpperCase();
    final payload = (match?.group(2) ?? raw).trim();
    final goldMatch = RegExp(
      r'(\d+)\s*GP\b',
      caseSensitive: false,
    ).firstMatch(payload);
    final gold = int.tryParse(goldMatch?.group(1) ?? '') ?? 0;
    final withoutGold = payload
        .replaceAll(
            RegExp(r',?\s*(and\s+)?\d+\s*GP\b', caseSensitive: false), '')
        .trim();
    final equipment = withoutGold
        .split(',')
        .map((item) => item.trim())
        .map((item) => item.replaceFirst(RegExp(r'^(and|or)\s+'), ''))
        .where((item) => item.isNotEmpty)
        .map(StartingEquipmentItem.fromText)
        .toList(growable: false);

    return StartingEquipmentOption(
      id: id,
      label: 'Option $id',
      text: payload,
      equipment: equipment,
      gold: gold,
    );
  }

  static String _buildOptionText({
    required List<StartingEquipmentItem> equipment,
    required int gold,
  }) {
    final parts = [
      ...equipment.map((item) => item.label),
      if (gold > 0) '$gold GP',
    ];
    return parts.join(', ');
  }

  static String _selectedId(List<String> entries, String prefix) {
    for (final entry in entries) {
      if (!entry.startsWith(prefix)) continue;
      return entry.replaceFirst(prefix, '').trim().toUpperCase();
    }
    return '';
  }

  static String _fallbackId(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  static int _int(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
