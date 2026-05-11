import '../../core/utils/dice_calculator.dart';
import '../remote/spell_dto.dart';

class WarlockChoiceService {
  WarlockChoiceService._();

  static const invocationEntryPrefix = 'class_choice:warlock_invocation:';
  static const mysticArcanumEntryPrefix =
      'class_choice:warlock_mystic_arcanum:';
  static const pactTomeCantripEntryPrefix =
      'class_choice:warlock_pact_tome_cantrip:';
  static const pactTomeRitualEntryPrefix =
      'class_choice:warlock_pact_tome_ritual:';

  static const pactOfTheBlade = 'pact_of_the_blade';
  static const pactOfTheChain = 'pact_of_the_chain';
  static const pactOfTheTome = 'pact_of_the_tome';
  static const thirstingBlade = 'thirsting_blade';

  static const archfeySubclass = 'warlock-archfey';
  static const celestialSubclass = 'warlock-celestial';
  static const fiendSubclass = 'warlock-fiend';
  static const greatOldOneSubclass = 'warlock-great-old-one';

  static const pactTomeCantripCount = 3;
  static const pactTomeRitualCount = 2;

  static const Map<String, _InvocationOption> _invocations = {
    'agonizing_blast': _InvocationOption(
      label: 'Agonizing Blast',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock, damaging Warlock cantrip',
      summary: 'Add Charisma modifier to one damaging Warlock cantrip.',
    ),
    'armor_of_shadows': _InvocationOption(
      label: 'Armor of Shadows',
      summary: 'Cast Mage Armor on yourself without a spell slot.',
      grantedSpellIds: ['mage-armor'],
    ),
    'ascendant_step': _InvocationOption(
      label: 'Ascendant Step',
      minLevel: 5,
      prerequisite: 'Level 5+ Warlock',
      summary: 'Cast Levitate on yourself without a spell slot.',
      grantedSpellIds: ['levitate'],
    ),
    'devils_sight': _InvocationOption(
      label: "Devil's Sight",
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'See normally in magical and nonmagical darkness within 120 ft.',
    ),
    'devouring_blade': _InvocationOption(
      label: 'Devouring Blade',
      minLevel: 12,
      requiredInvocations: [thirstingBlade],
      prerequisite: 'Level 12+ Warlock, Thirsting Blade',
      summary: 'Your pact weapon Extra Attack grants two extra attacks.',
    ),
    'eldritch_mind': _InvocationOption(
      label: 'Eldritch Mind',
      summary:
          'Gain Advantage on Constitution saves to maintain Concentration.',
    ),
    'eldritch_smite': _InvocationOption(
      label: 'Eldritch Smite',
      minLevel: 5,
      requiredInvocations: [pactOfTheBlade],
      prerequisite: 'Level 5+ Warlock, Pact of the Blade',
      summary:
          'Spend a Pact Magic slot after a pact weapon hit for extra Force damage and a possible knockdown.',
    ),
    'eldritch_spear': _InvocationOption(
      label: 'Eldritch Spear',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock, ranged damaging Warlock cantrip',
      summary: 'Greatly extend the range of one eligible Warlock cantrip.',
    ),
    'fiendish_vigor': _InvocationOption(
      label: 'Fiendish Vigor',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'Cast False Life on yourself without a slot at maximum value.',
      grantedSpellIds: ['false-life'],
    ),
    'gaze_of_two_minds': _InvocationOption(
      label: 'Gaze of Two Minds',
      minLevel: 5,
      prerequisite: 'Level 5+ Warlock',
      summary:
          'Perceive through a willing creature and cast from either space while maintained.',
    ),
    'gift_of_the_depths': _InvocationOption(
      label: 'Gift of the Depths',
      minLevel: 5,
      prerequisite: 'Level 5+ Warlock',
      summary:
          'Breathe underwater, gain a Swim Speed, and cast Water Breathing once per Long Rest.',
      grantedSpellIds: ['water-breathing'],
    ),
    'gift_of_the_protectors': _InvocationOption(
      label: 'Gift of the Protectors',
      minLevel: 9,
      requiredInvocations: [pactOfTheTome],
      prerequisite: 'Level 9+ Warlock, Pact of the Tome',
      summary:
          'Your Book of Shadows can save a written creature from dropping to 0 HP once per Long Rest.',
    ),
    'investment_of_the_chain_master': _InvocationOption(
      label: 'Investment of the Chain Master',
      minLevel: 5,
      requiredInvocations: [pactOfTheChain],
      prerequisite: 'Level 5+ Warlock, Pact of the Chain',
      summary:
          'Improve your familiar with movement, attacks, damage, DCs, and protection.',
    ),
    'lessons_of_the_first_ones': _InvocationOption(
      label: 'Lessons of the First Ones',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'Gain one Origin feat of your choice.',
    ),
    'lifedrinker': _InvocationOption(
      label: 'Lifedrinker',
      minLevel: 9,
      requiredInvocations: [pactOfTheBlade],
      prerequisite: 'Level 9+ Warlock, Pact of the Blade',
      summary:
          'Once per turn, add extra pact weapon damage and optionally spend a Hit Point Die to heal.',
    ),
    'mask_of_many_faces': _InvocationOption(
      label: 'Mask of Many Faces',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'Cast Disguise Self without a spell slot.',
      grantedSpellIds: ['disguise-self'],
    ),
    'master_of_myriad_forms': _InvocationOption(
      label: 'Master of Myriad Forms',
      minLevel: 5,
      prerequisite: 'Level 5+ Warlock',
      summary: 'Cast Alter Self without a spell slot.',
      grantedSpellIds: ['alter-self'],
    ),
    'misty_visions': _InvocationOption(
      label: 'Misty Visions',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'Cast Silent Image without a spell slot.',
      grantedSpellIds: ['silent-image'],
    ),
    'one_with_shadows': _InvocationOption(
      label: 'One with Shadows',
      minLevel: 5,
      prerequisite: 'Level 5+ Warlock',
      summary: 'Cast Invisibility on yourself while in dim light or darkness.',
      grantedSpellIds: ['invisibility'],
    ),
    'otherworldly_leap': _InvocationOption(
      label: 'Otherworldly Leap',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock',
      summary: 'Cast Jump on yourself without a spell slot.',
      grantedSpellIds: ['jump'],
    ),
    pactOfTheBlade: _InvocationOption(
      label: 'Pact of the Blade',
      summary:
          'Conjure or bond with a melee weapon, use it as a focus, and use Charisma for its attacks.',
    ),
    pactOfTheChain: _InvocationOption(
      label: 'Pact of the Chain',
      summary:
          'Learn Find Familiar, cast it without a slot, and unlock special familiar forms.',
      grantedSpellIds: ['find-familiar'],
    ),
    pactOfTheTome: _InvocationOption(
      label: 'Pact of the Tome',
      summary:
          'Conjure a Book of Shadows with three extra cantrips and two level 1 ritual spells.',
    ),
    'repelling_blast': _InvocationOption(
      label: 'Repelling Blast',
      minLevel: 2,
      prerequisite: 'Level 2+ Warlock, attack-roll Warlock cantrip',
      summary: 'Push a Large or smaller creature hit by your chosen cantrip.',
    ),
    thirstingBlade: _InvocationOption(
      label: 'Thirsting Blade',
      minLevel: 5,
      requiredInvocations: [pactOfTheBlade],
      prerequisite: 'Level 5+ Warlock, Pact of the Blade',
      summary:
          'Attack twice with your pact weapon when you take the Attack action.',
    ),
    'visions_of_distant_realms': _InvocationOption(
      label: 'Visions of Distant Realms',
      minLevel: 9,
      prerequisite: 'Level 9+ Warlock',
      summary: 'Cast Arcane Eye without a spell slot.',
      grantedSpellIds: ['arcane-eye'],
    ),
    'whispers_of_the_grave': _InvocationOption(
      label: 'Whispers of the Grave',
      minLevel: 7,
      prerequisite: 'Level 7+ Warlock',
      summary: 'Cast Speak with Dead without a spell slot.',
      grantedSpellIds: ['speak-with-dead'],
    ),
    'witch_sight': _InvocationOption(
      label: 'Witch Sight',
      minLevel: 15,
      prerequisite: 'Level 15+ Warlock',
      summary: 'Gain Truesight out to 30 ft.',
    ),
  };

  static bool isWarlock({required String className}) {
    return className.trim().toLowerCase() == 'warlock';
  }

  static bool isArchfey({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isWarlock(className: className) &&
        subclass.trim().toLowerCase() == archfeySubclass &&
        level >= 3;
  }

  static bool isCelestial({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isWarlock(className: className) &&
        subclass.trim().toLowerCase() == celestialSubclass &&
        level >= 3;
  }

  static bool isFiend({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isWarlock(className: className) &&
        subclass.trim().toLowerCase() == fiendSubclass &&
        level >= 3;
  }

  static bool isGreatOldOne({
    required String className,
    required String subclass,
    required int level,
  }) {
    return isWarlock(className: className) &&
        subclass.trim().toLowerCase() == greatOldOneSubclass &&
        level >= 3;
  }

  static bool isWarlockChoiceEntry(String entry) {
    return entry.startsWith(invocationEntryPrefix) ||
        entry.startsWith(mysticArcanumEntryPrefix) ||
        entry.startsWith(pactTomeCantripEntryPrefix) ||
        entry.startsWith(pactTomeRitualEntryPrefix);
  }

  static List<String> get invocationIds {
    return _invocations.keys.toList(growable: false);
  }

  static int invocationCountForLevel(int level) {
    if (level >= 18) return 10;
    if (level >= 15) return 9;
    if (level >= 12) return 8;
    if (level >= 9) return 7;
    if (level >= 7) return 6;
    if (level >= 5) return 5;
    if (level >= 2) return 3;
    if (level >= 1) return 1;
    return 0;
  }

  static List<String> selectedInvocations(Iterable<String> entries) {
    final selected = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(invocationEntryPrefix)) continue;
      final value = entry.replaceFirst(invocationEntryPrefix, '').trim();
      if (!_invocations.containsKey(value) || selected.contains(value)) {
        continue;
      }
      selected.add(value);
    }
    return selected;
  }

  static bool qualifiesForInvocation({
    required String invocationId,
    required int level,
    required Iterable<String> selectedInvocationIds,
  }) {
    final option = _invocations[invocationId];
    if (option == null || level < option.minLevel) return false;
    final selected = selectedInvocationIds.toSet();
    return option.requiredInvocations.every(selected.contains);
  }

  static Iterable<String> preservedEntriesForLevel(
    Iterable<String> entries, {
    required int characterLevel,
  }) {
    final keptInvocations = <String>[];
    final allowedMysticLevels =
        mysticArcanumSpellLevels(characterLevel).toSet();
    final keptArcanumLevels = <int>{};
    final keptTomeCantrips = <String>{};
    final keptTomeRituals = <String>{};
    final hasPactTome = selectedInvocations(entries).contains(pactOfTheTome);

    return entries.where((entry) {
      if (!isWarlockChoiceEntry(entry)) return false;

      if (entry.startsWith(invocationEntryPrefix)) {
        final invocationId =
            entry.replaceFirst(invocationEntryPrefix, '').trim();
        if (!_invocations.containsKey(invocationId)) return false;
        if (keptInvocations.length >= invocationCountForLevel(characterLevel)) {
          return false;
        }
        if (keptInvocations.contains(invocationId)) return false;
        if (!qualifiesForInvocation(
          invocationId: invocationId,
          level: characterLevel,
          selectedInvocationIds: keptInvocations,
        )) {
          return false;
        }
        keptInvocations.add(invocationId);
        return true;
      }

      if (entry.startsWith(mysticArcanumEntryPrefix)) {
        final parts = entry.split(':');
        if (parts.length < 4) return false;
        final spellLevel = int.tryParse(parts[2]);
        if (spellLevel == null || !allowedMysticLevels.contains(spellLevel)) {
          return false;
        }
        final spellId = entry
            .replaceFirst('$mysticArcanumEntryPrefix$spellLevel:', '')
            .trim();
        if (spellId.isEmpty || keptArcanumLevels.contains(spellLevel)) {
          return false;
        }
        keptArcanumLevels.add(spellLevel);
        return true;
      }

      if (!hasPactTome) return false;

      if (entry.startsWith(pactTomeCantripEntryPrefix)) {
        final spellId =
            entry.replaceFirst(pactTomeCantripEntryPrefix, '').trim();
        if (spellId.isEmpty ||
            keptTomeCantrips.length >= pactTomeCantripCount) {
          return false;
        }
        return keptTomeCantrips.add(spellId);
      }

      if (entry.startsWith(pactTomeRitualEntryPrefix)) {
        final spellId =
            entry.replaceFirst(pactTomeRitualEntryPrefix, '').trim();
        if (spellId.isEmpty || keptTomeRituals.length >= pactTomeRitualCount) {
          return false;
        }
        return keptTomeRituals.add(spellId);
      }

      return false;
    });
  }

  static bool hasInvocation(Iterable<String> entries, String invocationId) {
    return selectedInvocations(entries).contains(invocationId);
  }

  static bool needsPactTomeChoices({
    required String className,
    required int level,
    required Iterable<String> entries,
  }) {
    return isWarlock(className: className) &&
        level >= 1 &&
        hasInvocation(entries, pactOfTheTome);
  }

  static List<int> mysticArcanumSpellLevels(int characterLevel) {
    return [
      if (characterLevel >= 11) 6,
      if (characterLevel >= 13) 7,
      if (characterLevel >= 15) 8,
      if (characterLevel >= 17) 9,
    ];
  }

  static String? selectedMysticArcanumSpell(
    Iterable<String> entries, {
    required int spellLevel,
  }) {
    final prefix = '$mysticArcanumEntryPrefix$spellLevel:';
    for (final entry in entries.toList().reversed) {
      if (!entry.startsWith(prefix)) continue;
      final value = entry.replaceFirst(prefix, '').trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static List<String> selectedMysticArcanumSpells(Iterable<String> entries) {
    final selected = <String>[];
    for (final spellLevel in const [6, 7, 8, 9]) {
      final spell = selectedMysticArcanumSpell(
        entries,
        spellLevel: spellLevel,
      );
      if (spell != null && !selected.contains(spell)) {
        selected.add(spell);
      }
    }
    return selected;
  }

  static List<String> selectedPactTomeCantrips(Iterable<String> entries) {
    return _selectedSpellChoices(entries, pactTomeCantripEntryPrefix);
  }

  static List<String> selectedPactTomeRituals(Iterable<String> entries) {
    return _selectedSpellChoices(entries, pactTomeRitualEntryPrefix);
  }

  static List<String> baseGrantedSpellIds({
    required int level,
    required Iterable<String> entries,
  }) {
    final spellIds = <String>{
      if (level >= 9) 'contact-other-plane',
    };
    for (final invocationId in selectedInvocations(entries)) {
      spellIds.addAll(_invocations[invocationId]?.grantedSpellIds ?? const []);
    }
    return spellIds.toList();
  }

  static List<String> pactTomeSpellIds(Iterable<String> entries) {
    return [
      ...selectedPactTomeCantrips(entries),
      ...selectedPactTomeRituals(entries),
    ];
  }

  static int spellSaveDc({required int level, required int charisma}) {
    return 8 +
        DiceCalculator.getProficiencyBonus(level) +
        DiceCalculator.getModifier(charisma);
  }

  static int charismaMinimumOne(int charisma) {
    return DiceCalculator.getModifier(charisma).clamp(1, 99).toInt();
  }

  static String charismaModifierLabel(int charisma) {
    return _signed(DiceCalculator.getModifier(charisma));
  }

  static int healingLightPoolDice(int level) {
    return level >= 3 ? level + 1 : 0;
  }

  static int healingLightMaxDice(int charisma) {
    return charismaMinimumOne(charisma);
  }

  static int celestialResilienceSelfTempHp({
    required int level,
    required int charisma,
  }) {
    return level + DiceCalculator.getModifier(charisma);
  }

  static int celestialResilienceAllyTempHp({
    required int level,
    required int charisma,
  }) {
    return level ~/ 2 + DiceCalculator.getModifier(charisma);
  }

  static int darkOnesBlessingTempHp({
    required int level,
    required int charisma,
  }) {
    return (level + DiceCalculator.getModifier(charisma)).clamp(1, 999).toInt();
  }

  static int awakenedMindMiles(int charisma) {
    return charismaMinimumOne(charisma);
  }

  static int createThrallTempHp({
    required int level,
    required int charisma,
  }) {
    return level + DiceCalculator.getModifier(charisma);
  }

  static List<SpellDto> filterMysticArcanumOptions({
    required List<SpellDto> spells,
    required int spellLevel,
  }) {
    return spells
        .where(
          (spell) =>
              spell.level == spellLevel &&
              spell.classIndices.contains('warlock'),
        )
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  static List<SpellDto> filterPactTomeCantrips({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    return spells
        .where(
          (spell) => spell.level == 0 && !knownSpellIds.contains(spell.index),
        )
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  static List<SpellDto> filterPactTomeRituals({
    required List<SpellDto> spells,
    required Set<String> knownSpellIds,
  }) {
    return spells
        .where(
          (spell) =>
              spell.level == 1 &&
              spell.ritual &&
              !knownSpellIds.contains(spell.index),
        )
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  static String invocationLabel(String invocationId) {
    return _invocations[invocationId]?.label ?? invocationId;
  }

  static String invocationSummary(String invocationId) {
    return _invocations[invocationId]?.summary ?? '';
  }

  static String invocationPrerequisite(String invocationId) {
    return _invocations[invocationId]?.prerequisite ?? '';
  }

  static String invocationChoiceLabel(List<String> invocationIds) {
    return 'Eldritch Invocations: ${invocationIds.map(invocationLabel).join(', ')}';
  }

  static String _signed(int value) {
    if (value == 0) return '+ 0';
    return value > 0 ? '+ $value' : '- ${value.abs()}';
  }

  static List<String> _selectedSpellChoices(
    Iterable<String> entries,
    String prefix,
  ) {
    final selected = <String>[];
    for (final entry in entries) {
      if (!entry.startsWith(prefix)) continue;
      final value = entry.replaceFirst(prefix, '').trim();
      if (value.isEmpty || selected.contains(value)) continue;
      selected.add(value);
    }
    return selected;
  }
}

class _InvocationOption {
  final String label;
  final int minLevel;
  final List<String> requiredInvocations;
  final String prerequisite;
  final String summary;
  final List<String> grantedSpellIds;

  const _InvocationOption({
    required this.label,
    this.minLevel = 1,
    this.requiredInvocations = const [],
    this.prerequisite = '',
    required this.summary,
    this.grantedSpellIds = const [],
  });
}
