part of 'character_creation_provider.dart';

extension CreationStateAbilityBuilder on CreationState {
  _AdjustedAbilities _applyBackgroundBonuses() {
    var str = strength;
    var dex = dexterity;
    var con = constitution;
    var intScore = intelligence;
    var wis = wisdom;
    var cha = charisma;

    if (backgroundBonusMode == 'plus1all') {
      for (final ability in backgroundBonusChoices.take(3)) {
        switch (ability) {
          case 'str':
            str += 1;
            break;
          case 'dex':
            dex += 1;
            break;
          case 'con':
            con += 1;
            break;
          case 'int':
            intScore += 1;
            break;
          case 'wis':
            wis += 1;
            break;
          case 'cha':
            cha += 1;
            break;
        }
      }
    } else {
      if (backgroundBonusChoices.isNotEmpty) {
        switch (backgroundBonusChoices[0]) {
          case 'str':
            str += 2;
            break;
          case 'dex':
            dex += 2;
            break;
          case 'con':
            con += 2;
            break;
          case 'int':
            intScore += 2;
            break;
          case 'wis':
            wis += 2;
            break;
          case 'cha':
            cha += 2;
            break;
        }
      }
      if (backgroundBonusChoices.length > 1) {
        switch (backgroundBonusChoices[1]) {
          case 'str':
            str += 1;
            break;
          case 'dex':
            dex += 1;
            break;
          case 'con':
            con += 1;
            break;
          case 'int':
            intScore += 1;
            break;
          case 'wis':
            wis += 1;
            break;
          case 'cha':
            cha += 1;
            break;
        }
      }
    }

    return _AdjustedAbilities(
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intScore,
      wisdom: wis,
      charisma: cha,
    );
  }

  _AdjustedAbilities _applyLevelAdvancementBonuses(
    _AdjustedAbilities base,
    List<String> entries,
  ) {
    var str = base.strength;
    var dex = base.dexterity;
    var con = base.constitution;
    var intScore = base.intelligence;
    var wis = base.wisdom;
    var cha = base.charisma;

    void add(String ability, int amount) {
      switch (ability) {
        case 'str':
          str += amount;
          break;
        case 'dex':
          dex += amount;
          break;
        case 'con':
          con += amount;
          break;
        case 'int':
          intScore += amount;
          break;
        case 'wis':
          wis += amount;
          break;
        case 'cha':
          cha += amount;
          break;
      }
    }

    for (final entry in entries) {
      final payload = _advancementPayload(entry);
      if (payload.isEmpty) continue;

      if (payload.first == 'asi' && payload.length >= 2) {
        for (final bonus in _splitChoices(payload[1])) {
          final parts = bonus.split('+');
          if (parts.length != 2) continue;
          add(parts[0], int.tryParse(parts[1]) ?? 0);
        }
      }

      if (payload.first == 'feat' && payload.length >= 3) {
        final featId = payload[1];
        final ability = payload[2];
        if (!ProgressionService.isMagicInitiateId(featId) &&
            ability.isNotEmpty &&
            ability != '-') {
          add(ability, 1);
        }
      }
    }

    return _AdjustedAbilities(
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intScore,
      wisdom: wis,
      charisma: cha,
    );
  }

  _AdjustedAbilities _applyClassBonuses(_AdjustedAbilities base) {
    var str = base.strength;
    var dex = base.dexterity;
    var con = base.constitution;
    var intScore = base.intelligence;
    var wis = base.wisdom;
    var cha = base.charisma;

    if (MonkChoiceService.isMonk(className: className) && level >= 20) {
      dex = (dex + MonkChoiceService.bodyAndMindAbilityBonus)
          .clamp(0, MonkChoiceService.bodyAndMindAbilityMaximum)
          .toInt();
      wis = (wis + MonkChoiceService.bodyAndMindAbilityBonus)
          .clamp(0, MonkChoiceService.bodyAndMindAbilityMaximum)
          .toInt();
    }

    if (className == 'barbarian' && level >= 20) {
      str = (str + 4).clamp(0, 25).toInt();
      con = (con + 4).clamp(0, 25).toInt();
    }

    return _AdjustedAbilities(
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intScore,
      wisdom: wis,
      charisma: cha,
    );
  }

  int _calculateArmorClass(
    _AdjustedAbilities abilities,
    List<String> effectiveEquipment,
  ) {
    return EquipmentMechanicsService.calculateArmorClass(
      className: className,
      subclass: subclass,
      level: level,
      dexterity: abilities.dexterity,
      constitution: abilities.constitution,
      wisdom: abilities.wisdom,
      charisma: abilities.charisma,
      equipment: effectiveEquipment,
    );
  }

  int _calculateSpeed() {
    if (MonkChoiceService.isMonk(className: className)) {
      return speed + MonkChoiceService.unarmoredMovementBonus(level);
    }

    if (className == 'ranger') {
      return speed + ProgressionService.getRangerRovingSpeedBonus(level);
    }

    if (className == 'barbarian') {
      return speed + ProgressionService.getBarbarianFastMovementBonus(level);
    }

    return speed;
  }
}
