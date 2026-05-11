part of 'character_creation_provider.dart';

extension CreationStateAttackBuilder on CreationState {
  List<AttackModel> _syncClassAttacks({
    required List<AttackModel> existingAttacks,
    required CharacterModel previewCharacter,
  }) {
    if (className == 'rogue') {
      if (RogueChoiceService.isSoulknife(
        className: className,
        subclass: subclass,
        level: level,
      )) {
        return _syncSoulknifeAttacks(existingAttacks, previewCharacter);
      }

      return existingAttacks
          .where((attack) => !_isSoulknifeAttackName(attack.name))
          .toList();
    }

    if (className == 'ranger' ||
        className == 'paladin' ||
        className == 'barbarian' ||
        className == 'fighter' ||
        className == 'warlock') {
      return existingAttacks
          .map((attack) => _syncWeaponAttack(attack, previewCharacter))
          .toList();
    }

    if (BardChoiceService.isDance(
      className: className,
      subclass: subclass,
      level: level,
    )) {
      return _syncDanceAttacks(existingAttacks, previewCharacter);
    }

    if (className == 'bard') {
      return existingAttacks
          .where((attack) => !_isDanceStrikeName(attack.name))
          .toList();
    }

    if (!MonkChoiceService.isMonk(className: className)) {
      return List<AttackModel>.from(existingAttacks);
    }

    final synced = existingAttacks
        .map((attack) => _syncMonkAttack(attack, previewCharacter))
        .toList();

    final unarmedStrike = _buildMonkUnarmedStrike(previewCharacter);
    final unarmedIndex = synced.indexWhere(
      (attack) => attack.name.trim().toLowerCase() == 'unarmed strike',
    );

    if (unarmedIndex >= 0) {
      synced[unarmedIndex] = unarmedStrike;
    } else {
      synced.insert(0, unarmedStrike);
    }

    return synced;
  }

  List<AttackModel> _syncDanceAttacks(
    List<AttackModel> existingAttacks,
    CharacterModel previewCharacter,
  ) {
    final synced = existingAttacks
        .where((attack) => !_isDanceStrikeName(attack.name))
        .toList();
    synced.insert(0, _buildDanceStrike(previewCharacter));
    return synced;
  }

  bool _isDanceStrikeName(String name) {
    return name.trim().toLowerCase() == 'unarmed strike (dance)';
  }

  AttackModel _buildDanceStrike(CharacterModel previewCharacter) {
    final attackBonus = DiceCalculator.getModifier(previewCharacter.dexterity) +
        DiceCalculator.getProficiencyBonus(previewCharacter.level) -
        (previewCharacter.exhaustionLevel * 2);

    return AttackModel(
      name: 'Unarmed Strike (Dance)',
      attackBonus: attackBonus >= 0 ? '+$attackBonus' : '$attackBonus',
      damageDice:
          '${BardChoiceService.bardicInspirationDie(previewCharacter.level)} + DEX',
      damageType: 'Bludgeoning',
      range: '5 ft',
      properties: 'Dexterity, Agile Strikes, adds DEX modifier',
    );
  }

  List<AttackModel> _syncSoulknifeAttacks(
    List<AttackModel> existingAttacks,
    CharacterModel previewCharacter,
  ) {
    final synced = existingAttacks
        .where((attack) => !_isSoulknifeAttackName(attack.name))
        .toList();

    synced.insert(
      0,
      _buildSoulknifeAttack(
        previewCharacter,
        name: 'Psychic Blade',
        damageDice: '1d6',
        properties: 'Finesse, Thrown (60/120), Vex',
      ),
    );
    synced.insert(
      1,
      _buildSoulknifeAttack(
        previewCharacter,
        name: 'Psychic Blade (Bonus Action)',
        damageDice: '1d4',
        properties: 'Bonus Action, Finesse, Thrown (60/120), Vex',
      ),
    );

    return synced;
  }

  bool _isSoulknifeAttackName(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized == 'psychic blade' ||
        normalized == 'psychic blade (bonus action)';
  }

  AttackModel _buildSoulknifeAttack(
    CharacterModel previewCharacter, {
    required String name,
    required String damageDice,
    required String properties,
  }) {
    final attackAbility =
        previewCharacter.dexterity >= previewCharacter.strength
            ? previewCharacter.dexterity
            : previewCharacter.strength;
    final attackBonus = DiceCalculator.getModifier(attackAbility) +
        DiceCalculator.getProficiencyBonus(previewCharacter.level) -
        (previewCharacter.exhaustionLevel * 2);

    return AttackModel(
      name: name,
      attackBonus: attackBonus >= 0 ? '+$attackBonus' : '$attackBonus',
      damageDice: damageDice,
      damageType: 'Psychic',
      range: '60/120 ft',
      properties: properties,
      isMagic: true,
    );
  }

  AttackModel _syncWeaponAttack(
    AttackModel attack,
    CharacterModel previewCharacter,
  ) {
    if (attack.isMagic) {
      return attack;
    }

    final weapon = _findWeaponByName(attack.name);
    if (weapon == null) {
      return attack;
    }

    return attack.copyWith(
      attackBonus: WeaponBonusCalculator.calculateWeaponBonus(
        weapon,
        previewCharacter,
      ),
      damageDice: WeaponBonusCalculator.calculateWeaponDamageDice(
        weapon,
        previewCharacter,
      ),
      damageType: WeaponBonusCalculator.calculateWeaponDamageType(
        weapon,
        previewCharacter,
      ),
    );
  }

  AttackModel _syncMonkAttack(
    AttackModel attack,
    CharacterModel previewCharacter,
  ) {
    if (attack.isMagic) {
      return attack;
    }

    final weapon = _findWeaponByName(attack.name);
    if (weapon == null || !WeaponBonusCalculator.isMonkWeapon(weapon)) {
      return attack;
    }

    return _syncWeaponAttack(attack, previewCharacter);
  }

  AttackModel _buildMonkUnarmedStrike(CharacterModel previewCharacter) {
    final attackBonus = DiceCalculator.getModifier(
          previewCharacter.dexterity >= previewCharacter.strength
              ? previewCharacter.dexterity
              : previewCharacter.strength,
        ) +
        DiceCalculator.getProficiencyBonus(previewCharacter.level) -
        (previewCharacter.exhaustionLevel * 2);

    return AttackModel(
      name: 'Unarmed Strike',
      attackBonus: attackBonus >= 0 ? '+$attackBonus' : '$attackBonus',
      damageDice: MonkChoiceService.martialArtsDie(previewCharacter.level),
      damageType:
          previewCharacter.level >= 6 ? 'Bludgeoning / Force' : 'Bludgeoning',
      range: '5 ft',
      properties: 'Bonus Action via Martial Arts',
    );
  }

  DndWeapon? _findWeaponByName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final weapon in kDndWeapons) {
      if (weapon.name.toLowerCase() == normalized) {
        return weapon;
      }
    }

    return null;
  }
}
