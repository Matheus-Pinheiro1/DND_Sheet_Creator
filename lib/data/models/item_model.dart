class ItemModel {
  final int id;
  final String name;
  final String itemType;
  final String rarity;
  final bool requiresAttunement;
  final String publisher;

  final String? damage;
  final String? damageType;
  final String? range;
  final String? weaponProperties;
  final String? mastery;

  final String? ac;
  final String? stealth;
  final String? weight;

  const ItemModel({
    required this.id,
    required this.name,
    required this.itemType,
    required this.rarity,
    required this.requiresAttunement,
    required this.publisher,
    this.damage,
    this.damageType,
    this.range,
    this.weaponProperties,
    this.mastery,
    this.ac,
    this.stealth,
    this.weight,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: (json['i'] as num).toInt(),
      name: json['n'] as String? ?? '',
      itemType: json['t'] as String? ?? 'Other',
      rarity: json['r'] as String? ?? 'unknown',
      requiresAttunement: json['a'] as bool? ?? false,
      publisher: json['pub'] as String? ?? '',
      damage: json['dmg'] as String?,
      damageType: json['dmt'] as String?,
      range: json['rng'] as String?,
      weaponProperties: json['prp'] as String?,
      mastery: json['mst'] as String?,
      ac: json['ac'] as String?,
      stealth: json['stl'] as String?,
      weight: json['wt'] as String?,
    );
  }

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
}
