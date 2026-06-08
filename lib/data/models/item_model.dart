class ItemModel {
  final String id;
  final String name;
  final String itemType;
  final String rarity;
  final bool requiresAttunement;
  final String publisher;
  final String description;

  final String? damage;
  final String? damageType;
  final String? range;
  final String? weaponProperties;
  final String? mastery;

  final String? ac;
  final String? stealth;
  final String? weight;
  final String? cost;

  const ItemModel({
    required this.id,
    required this.name,
    required this.itemType,
    required this.rarity,
    required this.requiresAttunement,
    required this.publisher,
    this.description = '',
    this.damage,
    this.damageType,
    this.range,
    this.weaponProperties,
    this.mastery,
    this.ac,
    this.stealth,
    this.weight,
    this.cost,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: (json['id'] ?? json['i'] ?? '').toString(),
      name: (json['name'] ?? json['n'] ?? '').toString(),
      itemType: (json['itemType'] ?? json['t'] ?? 'Other').toString(),
      rarity: (json['rarity'] ?? json['r'] ?? 'standard').toString(),
      requiresAttunement:
          json['requiresAttunement'] as bool? ?? json['a'] as bool? ?? false,
      publisher: (json['publisher'] ?? json['pub'] ?? '').toString(),
      description: (json['description'] ?? json['desc'] ?? '').toString(),
      damage: json['damage'] as String? ?? json['dmg'] as String?,
      damageType: json['damageType'] as String? ?? json['dmt'] as String?,
      range: json['range'] as String? ?? json['rng'] as String?,
      weaponProperties:
          json['weaponProperties'] as String? ?? json['prp'] as String?,
      mastery: json['mastery'] as String? ?? json['mst'] as String?,
      ac: json['ac'] as String?,
      stealth: json['stealth'] as String? ?? json['stl'] as String?,
      weight: json['weight'] as String? ?? json['wt'] as String?,
      cost: json['cost'] as String?,
    );
  }

  factory ItemModel.fromOpen5e(Map<String, dynamic> json) {
    final category = _map(json['category']);
    final rarity = _map(json['rarity']);
    final document = _map(json['document']);
    final publisher = _map(document['publisher']);
    final weapon = _map(json['weapon']);
    final armor = _map(json['armor']);

    return ItemModel(
      id: (json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['desc'] ?? json['description'] ?? '').toString(),
      itemType: _normalizeType(category['name']),
      rarity: _normalizeRarity(rarity['key'] ?? rarity['name']),
      requiresAttunement: json['requires_attunement'] == true,
      publisher:
          (publisher['name'] ?? document['display_name'] ?? '').toString(),
      damage: weapon['damage_dice']?.toString(),
      damageType: _nestedName(weapon['damage_type']),
      range: weapon['range']?.toString(),
      weaponProperties: _weaponProperties(weapon),
      ac: armor['ac_display']?.toString() ?? armor['ac_base']?.toString(),
      stealth:
          armor['grants_stealth_disadvantage'] == true ? 'Disadvantage' : null,
      weight: _cleanDecimal(json['weight']),
      cost: _cleanDecimal(json['cost']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'itemType': itemType,
        'rarity': rarity,
        'requiresAttunement': requiresAttunement,
        'publisher': publisher,
        'description': description,
        'damage': damage,
        'damageType': damageType,
        'range': range,
        'weaponProperties': weaponProperties,
        'mastery': mastery,
        'ac': ac,
        'stealth': stealth,
        'weight': weight,
        'cost': cost,
      };

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        itemType.toLowerCase().contains(q) ||
        rarity.toLowerCase().contains(q) ||
        (damage?.toLowerCase().contains(q) ?? false) ||
        (damageType?.toLowerCase().contains(q) ?? false) ||
        (weaponProperties?.toLowerCase().contains(q) ?? false) ||
        (mastery?.toLowerCase().contains(q) ?? false) ||
        (publisher.toLowerCase().contains(q));
  }

  String get rarityLabel => switch (rarity) {
        'standard' => 'Standard',
        'common' => 'Common',
        'uncommon' => 'Uncommon',
        'rare' => 'Rare',
        'very rare' => 'Very Rare',
        'legendary' => 'Legendary',
        'artifact' => 'Artifact',
        'epic' => 'Epic',
        'varies' => 'Varies',
        _ => 'Unknown',
      };

  static Map<String, dynamic> _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  static String _normalizeType(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return 'Other';

    final lower = raw.toLowerCase();
    if (lower.contains('wondrous')) return 'Wondrous Item';
    if (lower.contains('adventuring')) return 'Adventuring Gear';
    if (lower.contains('weapon')) return 'Weapon';
    if (lower.contains('armor')) return 'Armor';
    if (lower.contains('potion')) return 'Potion';
    if (lower.contains('ring')) return 'Ring';
    if (lower.contains('scroll')) return 'Scroll';
    if (lower.contains('staff')) return 'Staff';
    if (lower.contains('wand')) return 'Wand';
    if (lower.contains('rod')) return 'Rod';
    if (lower.contains('tool')) return 'Tool';
    if (lower.contains('vehicle')) return 'Vehicle';

    return raw;
  }

  static String _normalizeRarity(dynamic value) {
    final raw = value?.toString().toLowerCase().replaceAll('-', ' ').trim();
    if (raw == null || raw.isEmpty) return 'standard';

    if (raw == 'very rare') return 'very rare';
    if (raw == 'common') return 'common';
    if (raw == 'uncommon') return 'uncommon';
    if (raw == 'rare') return 'rare';
    if (raw == 'legendary') return 'legendary';
    if (raw == 'artifact') return 'artifact';
    if (raw == 'epic') return 'epic';
    if (raw == 'varies') return 'varies';

    return 'standard';
  }

  static String? _nestedName(dynamic value) {
    if (value is Map) return value['name']?.toString();
    return value?.toString();
  }

  static String? _weaponProperties(Map<String, dynamic> weapon) {
    final props = weapon['properties'];
    if (props is! List) return null;

    final names = props
        .map((p) {
          if (p is Map) return _nestedName(p['property'] ?? p);
          return null;
        })
        .whereType<String>()
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return names.isEmpty ? null : names.join(', ');
  }

  static String? _cleanDecimal(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    final number = num.tryParse(text);
    if (number == null) return text;
    if (number == 0) return null;
    if (number % 1 == 0) return number.toInt().toString();
    return number.toString();
  }
}
