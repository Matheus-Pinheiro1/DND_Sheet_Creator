part of 'encounter_screen.dart';

class _MonsterCombatReference extends ConsumerWidget {
  final EncounterParticipant participant;

  const _MonsterCombatReference({required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterAsync = ref.watch(
      monsterDetailProvider(participant.monsterIndex),
    );

    return _SheetSection(
      title: 'Monster Actions',
      trailing: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.gold,
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.push(
            '/monsters/${Uri.encodeComponent(participant.monsterIndex)}',
          );
        },
        icon: const Icon(Icons.open_in_new, size: 14),
        label: Text(
          'Full sheet',
          style: AppTextStyles.lato(color: AppTheme.gold, fontSize: 12),
        ),
      ),
      child: monsterAsync.when(
        loading: () => const _MonsterReferenceLoading(),
        error: (_, __) => _MonsterReferenceError(
          onRetry: () => ref.invalidate(
            monsterDetailProvider(participant.monsterIndex),
          ),
        ),
        data: (monster) => _MonsterCombatEntries(monster: monster),
      ),
    );
  }
}

class _MonsterReferenceLoading extends StatelessWidget {
  const _MonsterReferenceLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          'Loading stat block...',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _MonsterReferenceError extends StatelessWidget {
  final VoidCallback onRetry;

  const _MonsterReferenceError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Could not load this monster stat block.',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _MonsterCombatEntries extends StatelessWidget {
  final MonsterDetailDto monster;

  const _MonsterCombatEntries({required this.monster});

  @override
  Widget build(BuildContext context) {
    final groups = [
      _MonsterEntryGroupData('Special Abilities', monster.specialAbilities),
      _MonsterEntryGroupData('Actions', monster.actions),
      _MonsterEntryGroupData('Bonus Actions', monster.bonusActions),
      _MonsterEntryGroupData('Reactions', monster.reactions),
      _MonsterEntryGroupData('Legendary Actions', monster.legendaryActions),
    ].where((group) => group.entries.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonsterAbilityGrid(monster: monster),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MonsterInfoPill(label: 'Speed', value: _formatMap(monster.speed)),
            if (monster.senses.isNotEmpty)
              _MonsterInfoPill(
                label: 'Senses',
                value: _formatMap(monster.senses),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (groups.isEmpty)
          Text(
            'No combat actions listed for this monster.',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 13),
          )
        else
          for (var i = 0; i < groups.length; i++) ...[
            _MonsterEntryGroup(group: groups[i]),
            if (i != groups.length - 1) const SizedBox(height: 16),
          ],
      ],
    );
  }

  static String _formatMap(Map<String, dynamic> values) {
    if (values.isEmpty) return '-';
    return values.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

class _MonsterAbilityGrid extends StatelessWidget {
  final MonsterDetailDto monster;

  const _MonsterAbilityGrid({required this.monster});

  @override
  Widget build(BuildContext context) {
    final abilities = [
      _MonsterAbility('STR', monster.strength),
      _MonsterAbility('DEX', monster.dexterity),
      _MonsterAbility('CON', monster.constitution),
      _MonsterAbility('INT', monster.intelligence),
      _MonsterAbility('WIS', monster.wisdom),
      _MonsterAbility('CHA', monster.charisma),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final columns = constraints.maxWidth < 360 ? 2 : 3;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: abilities
              .map((ability) => SizedBox(
                    width: tileWidth,
                    child: _MonsterAbilityTile(ability: ability),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MonsterAbility {
  final String label;
  final int score;

  const _MonsterAbility(this.label, this.score);

  String get modifier {
    final value = DiceCalculator.getModifier(score);
    return value >= 0 ? '+$value' : '$value';
  }
}

class _MonsterAbilityTile extends StatelessWidget {
  final _MonsterAbility ability;

  const _MonsterAbilityTile({required this.ability});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ability.label,
            style: AppTextStyles.lato(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${ability.score}',
                style: AppTextStyles.cinzel(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                ability.modifier,
                style: AppTextStyles.lato(
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

class _MonsterEntryGroupData {
  final String title;
  final List<Map<String, dynamic>> entries;

  const _MonsterEntryGroupData(this.title, this.entries);
}

class _MonsterInfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _MonsterInfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}

class _MonsterEntryGroup extends StatelessWidget {
  final _MonsterEntryGroupData group;

  const _MonsterEntryGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.gold.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < group.entries.length; i++) ...[
                _MonsterEntry(entry: group.entries[i]),
                if (i != group.entries.length - 1)
                  const Divider(height: 20, color: Colors.white10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonsterEntry extends StatelessWidget {
  final Map<String, dynamic> entry;

  const _MonsterEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final name = (entry['name'] ?? '').toString().trim();
    final description = _entryDescription(entry);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(
            name,
            style: AppTextStyles.cinzel(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (description.isNotEmpty) ...[
          if (name.isNotEmpty) const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  static String _entryDescription(Map<String, dynamic> entry) {
    final desc = entry['desc'];
    if (desc is List) {
      final text = desc
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .join('\n');
      if (text.isNotEmpty) return text;
    }

    final text = desc?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;

    final fallback = <String>[];
    final attackBonus = entry['attack_bonus'];
    final dc = _formatDc(entry['dc']);
    final damage = _formatDamage(entry['damage']);

    if (attackBonus != null) fallback.add('Attack bonus: +$attackBonus');
    if (dc.isNotEmpty) fallback.add('Save: $dc');
    if (damage.isNotEmpty) fallback.add('Damage: $damage');

    return fallback.join('\n');
  }

  static String _formatDc(dynamic dc) {
    if (dc is! Map) return '';

    final value = dc['dc_value'];
    final type = dc['dc_type'];
    final typeName = type is Map ? type['name'] : type;
    final parts = [
      if (value != null) 'DC $value',
      if (typeName != null) typeName.toString(),
    ];

    return parts.join(' ');
  }

  static String _formatDamage(dynamic damage) {
    if (damage is! List) return '';

    return damage
        .map((item) {
          if (item is! Map) return item.toString();

          final dice = item['damage_dice']?.toString() ?? '';
          final damageType = item['damage_type'];
          final damageTypeName = damageType is Map ? damageType['name'] : null;
          return [
            if (dice.isNotEmpty) dice,
            if (damageTypeName != null) damageTypeName.toString(),
          ].join(' ');
        })
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
  }
}

// ── Add player sheet ─────────────────────────────────────────────────────────
