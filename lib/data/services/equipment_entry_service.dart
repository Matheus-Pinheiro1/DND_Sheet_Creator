class EquipmentEntry {
  final String name;
  final String description;
  final bool equipped;

  const EquipmentEntry({
    required this.name,
    this.description = '',
    this.equipped = true,
  });

  EquipmentEntry copyWith({
    String? name,
    String? description,
    bool? equipped,
  }) {
    return EquipmentEntry(
      name: name ?? this.name,
      description: description ?? this.description,
      equipped: equipped ?? this.equipped,
    );
  }
}

class EquipmentEntryService {
  EquipmentEntryService._();

  static EquipmentEntry parse(String raw) {
    final parts = raw.split('||');
    final name = parts.isNotEmpty ? parts.first.trim() : raw.trim();
    final descriptionParts = <String>[];
    var equipped = true;

    for (final part in parts.skip(1)) {
      final trimmed = part.trim();
      final normalized = trimmed.toLowerCase();

      if (normalized == 'equipped:false') {
        equipped = false;
      } else if (normalized == 'equipped:true') {
        equipped = true;
      } else if (trimmed.isNotEmpty) {
        descriptionParts.add(part);
      }
    }

    return EquipmentEntry(
      name: name,
      description: descriptionParts.join('||').trim(),
      equipped: equipped,
    );
  }

  static String encode(EquipmentEntry entry) {
    final parts = <String>[
      entry.name.trim(),
      if (entry.description.trim().isNotEmpty) entry.description.trim(),
      'equipped:${entry.equipped}',
    ];
    return parts.join('||');
  }

  static bool isEquipped(String raw) {
    return parse(raw).equipped;
  }

  static List<String> equippedEntries(List<String> equipment) {
    return equipment.where(isEquipped).toList(growable: false);
  }
}
