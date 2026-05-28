import 'dart:math';

import 'dice_calculator.dart';

class MonsterCombatHelpers {
  MonsterCombatHelpers._();

  static final Random _random = Random();

  static int rollInitiative(int dexterity, {Random? random}) {
    final source = random ?? _random;
    return source.nextInt(20) + 1 + DiceCalculator.getModifier(dexterity);
  }

  static int legendaryActionsMax(List<Map<String, dynamic>> actions) {
    return actions.isEmpty ? 0 : 3;
  }

  static int legendaryResistancesMax(
    List<Map<String, dynamic>> specialAbilities,
  ) {
    var total = 0;

    for (final ability in specialAbilities) {
      final name = (ability['name'] ?? '').toString();
      final description = _descriptionText(ability['desc']);
      final text = '$name\n$description';

      if (!text.toLowerCase().contains('legendary resistance')) {
        continue;
      }

      total += _usesPerDay(text) ?? 1;
    }

    return total;
  }

  static int? _usesPerDay(String text) {
    final match = RegExp(
      r'(\d+)\s*/\s*day',
      caseSensitive: false,
    ).firstMatch(text);

    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  static String _descriptionText(dynamic value) {
    if (value is List) {
      return value.map((entry) => entry.toString()).join('\n');
    }
    return value?.toString() ?? '';
  }
}
