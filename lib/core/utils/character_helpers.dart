import '../../data/models/character_model.dart';
import '../../data/services/progression_service.dart';

class CharacterHelpers {
  CharacterHelpers._();

  static int spellcastingModifier(CharacterModel character) {
    switch (character.spellcastingAbility) {
      case 'str':
        return ((character.strength - 10) / 2).floor();
      case 'dex':
        return ((character.dexterity - 10) / 2).floor();
      case 'con':
        return ((character.constitution - 10) / 2).floor();
      case 'int':
        return ((character.intelligence - 10) / 2).floor();
      case 'wis':
        return ((character.wisdom - 10) / 2).floor();
      case 'cha':
        return ((character.charisma - 10) / 2).floor();
      default:
        return 0;
    }
  }
}

class CharacterSpellProxy implements CharacterModelLike {
  final CharacterModel character;
  CharacterSpellProxy(this.character);

  @override
  String get className => character.className;

  @override
  int get level => character.level;

  @override
  int get spellcastingModifier =>
      CharacterHelpers.spellcastingModifier(character);
}
