part of '../tab_features.dart';

class _TabFeaturesDecorator {
  final CharacterModel character;

  const _TabFeaturesDecorator(this.character);

  String _selectedChoiceValue(String prefix) {
    for (final entry in character.levelAdvancements.reversed) {
      if (entry.startsWith(prefix)) {
        return entry.replaceFirst(prefix, '');
      }
    }
    return '';
  }

  String _slotSummary(Map<int, int> slots) {
    if (slots.isEmpty) return 'none';
    final levels = slots.keys.toList()..sort();
    return levels.map((level) => 'L$level ${slots[level]}').join(' / ');
  }
}
