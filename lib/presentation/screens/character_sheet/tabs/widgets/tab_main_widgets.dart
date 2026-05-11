part of '../tab_main.dart';

class _QuickStatsCard extends StatelessWidget {
  final CharacterModel c;
  final int profBonus;

  const _QuickStatsCard(
      {required CharacterModel character, required this.profBonus})
      : c = character;

  int _passive(String skillIndex) {
    const ability = {
      'perception': 'wis',
      'investigation': 'int',
      'insight': 'wis',
    };
    final ab = ability[skillIndex] ?? 'wis';
    final score = _score(ab);
    final mod = DiceCalculator.getModifier(score);
    final isProficient = c.allProficientSkills.contains(skillIndex);
    final hasExpertise = _hasExpertise(skillIndex);
    final hasJackOfAllTrades = BardChoiceService.hasJackOfAllTrades(
      className: c.className,
      level: c.level,
    );
    final proficiencyBonus = hasExpertise
        ? profBonus * 2
        : isProficient
            ? profBonus
            : hasJackOfAllTrades
                ? profBonus ~/ 2
                : 0;
    return 10 + mod + proficiencyBonus;
  }

  bool _hasExpertise(String skillIndex) {
    final label = skillIndex
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
    return c.proficiencies.contains('Expertise: $label');
  }

  int _score(String ab) {
    switch (ab) {
      case 'str':
        return c.strength;
      case 'dex':
        return c.dexterity;
      case 'con':
        return c.constitution;
      case 'int':
        return c.intelligence;
      case 'wis':
        return c.wisdom;
      case 'cha':
        return c.charisma;
      default:
        return 10;
    }
  }

  int get _carryCapacity => c.strength * 15;
  String get _encumbranceLabel => 'Up to $_carryCapacity lbs';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Reference',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          Row(children: [
            _PassiveStat('👁 Passive\nPerception', _passive('perception')),
            const SizedBox(width: 8),
            _PassiveStat(
                '🔍 Passive\nInvestigation', _passive('investigation')),
            const SizedBox(width: 8),
            _PassiveStat('💡 Passive\nInsight', _passive('insight')),
          ]),
          const Divider(height: 20, color: Colors.white12),
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              Text('Carry Capacity: ',
                  style: AppTextStyles.lato(
                    color: Colors.white54,
                    fontSize: 13,
                  )),
              Text(
                _encumbranceLabel,
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassiveStat extends StatelessWidget {
  final String label;
  final int value;
  const _PassiveStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(children: [
          Text('$value',
              style: AppTextStyles.cinzel(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 9,
                height: 1.3,
              ),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _CharacterHeader extends StatelessWidget {
  final CharacterModel character;
  final int profBonus;
  final WidgetRef ref;

  const _CharacterHeader({
    required this.character,
    required this.profBonus,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        CharacterAvatar(
            name: character.name,
            avatarChoice: character.avatarChoice,
            size: 64,
            onTap: () => _showAvatarPicker(context)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine('Species', character.raceName),
              _InfoLine('Class', character.classDisplayName),
              if (character.subclassName.isNotEmpty)
                _InfoLine('Subclass', character.subclassName),
              _InfoLine('Background', character.backgroundName),
              _InfoLine('Alignment', character.alignment),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            await ref.read(charactersProvider.notifier).updateCharacter(
                  character.copyWith(inspiration: !character.inspiration),
                );
          },
          child: Column(children: [
            Icon(
              character.inspiration ? Icons.star : Icons.star_border,
              color: character.inspiration ? AppTheme.gold : Colors.white24,
              size: 28,
            ),
            Text('Inspiration',
                style: AppTextStyles.lato(
                  color: Colors.white30,
                  fontSize: 9,
                )),
          ]),
        ),
      ]),
    );
  }

  Future<void> _showAvatarPicker(BuildContext context) async {
    const avatarOptions = [
      '⚙️',
      '🪓',
      '🎸',
      '🙏',
      '🌲',
      '🐻',
      '⚔️',
      '🥊',
      '🛡',
      '🏹',
      '🥷',
      '🔥',
      '✒️',
      '🧙‍♂️',
      '🧝',
      '🧝‍♀️',
      '☠️',
    ];
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Avatar',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...avatarOptions.map(
                    (avatar) => GestureDetector(
                      onTap: () => Navigator.of(context).pop(avatar),
                      child: CharacterAvatar(
                        name: character.name,
                        avatarChoice: avatar,
                        size: 56,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(''),
                    child: CharacterAvatar(
                      name: character.name,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;
    await ref.read(charactersProvider.notifier).updateCharacter(
          choice.isEmpty
              ? character.copyWith(clearAvatarChoice: true)
              : character.copyWith(avatarChoice: choice),
        );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: [
        Text('$label: ',
            style: AppTextStyles.lato(
              color: Colors.white30,
              fontSize: 12,
            )),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.lato(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

class _AbilityScoresGrid extends StatelessWidget {
  final CharacterModel character;
  const _AbilityScoresGrid({required this.character});

  @override
  Widget build(BuildContext context) {
    final pairs = [
      ('STR', character.strength),
      ('DEX', character.dexterity),
      ('CON', character.constitution),
      ('INT', character.intelligence),
      ('WIS', character.wisdom),
      ('CHA', character.charisma),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children:
          pairs.map((p) => _AbilityBox(label: p.$1, score: p.$2)).toList(),
    );
  }
}

class _AbilityBox extends StatelessWidget {
  final String label;
  final int score;
  const _AbilityBox({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final mod = DiceCalculator.getModifier(score);
    return StatBox(
      label: label,
      value: '${mod >= 0 ? '+' : ''}$mod\n$score',
      color: AppTheme.gold,
    );
  }
}

class _ProficiencyRow extends StatelessWidget {
  final String name;
  final String badge;
  final int value;
  final bool proficient;
  final bool fromBackground;
  final VoidCallback? onTap;

  const _ProficiencyRow({
    required this.name,
    required this.badge,
    required this.value,
    required this.proficient,
    this.fromBackground = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SkillRow(
      name: name,
      badge: badge,
      value: value,
      proficient: proficient,
      fromBackground: fromBackground,
      onTap: onTap,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          )),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _PersonalityBlock extends StatelessWidget {
  final String label;
  final String value;
  const _PersonalityBlock(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 11,
            )),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            )),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip(this.label, this.bg, this.fg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg == fg ? fg.withValues(alpha: 0.16) : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.65)),
      ),
      child: Text(label, style: AppTextStyles.lato(color: fg, fontSize: 12)),
    );
  }
}
