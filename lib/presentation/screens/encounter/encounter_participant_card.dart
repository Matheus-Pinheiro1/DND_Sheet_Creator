part of 'encounter_screen.dart';

class _ParticipantCard extends StatelessWidget {
  final EncounterParticipant participant;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onJumpToTurn;
  final void Function(int) onDamage;
  final void Function(int) onHeal;
  final void Function(int)? onSetInitiative;

  const _ParticipantCard({
    required this.participant,
    required this.isActive,
    required this.onTap,
    required this.onJumpToTurn,
    required this.onDamage,
    required this.onHeal,
    this.onSetInitiative,
  });

  @override
  Widget build(BuildContext context) {
    final p = participant;
    final isDefeated = p.isDefeated;
    final tagColor = p.colorTag == 0 ? null : encounterColorForTag(p.colorTag);

    final borderColor = isActive
        ? AppTheme.gold
        : isDefeated
            ? Colors.white12
            : tagColor ?? Colors.white10;
    final cardColor =
        isActive ? AppTheme.darkBrown.withValues(alpha: 0.9) : AppTheme.ashGray;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Opacity(
        opacity: isDefeated ? 0.5 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _InitiativeBadge(
                      initiative: p.initiative,
                      isActive: isActive,
                      onTap: onSetInitiative != null
                          ? () => _showInitiativeModal(
                              context, p.initiative, onSetInitiative!)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isDefeated)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.close,
                                      size: 14, color: AppTheme.crimson),
                                ),
                              if (isActive)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.arrow_right,
                                      size: 18, color: AppTheme.gold),
                                ),
                              if (tagColor != null) ...[
                                _ColorMarker(color: tagColor),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  isDefeated ? '${p.name} (Defeated)' : p.name,
                                  style: AppTextStyles.cinzel(
                                    color: isDefeated
                                        ? Colors.white38
                                        : isActive
                                            ? AppTheme.gold
                                            : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (p.visibleOriginalName.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              '(${p.visibleOriginalName})',
                              style: AppTextStyles.lato(
                                color: Colors.white38,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          Text(
                            p.isPlayer
                                ? 'Player Character'
                                : '${_capitalize(p.type)} - CR ${p.crLabel}',
                            style: AppTextStyles.lato(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    _AcBadge(ac: p.armorClass),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: isActive ? 'Current turn' : 'Jump to turn',
                      icon: Icon(
                        isActive
                            ? Icons.play_circle_fill
                            : Icons.low_priority_outlined,
                        size: 18,
                      ),
                      color: isActive ? AppTheme.gold : Colors.white54,
                      onPressed: isActive ? null : onJumpToTurn,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: Colors.white54,
                      onPressed: onTap,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _HpBar(participant: p),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuickButton(
                      icon: Icons.remove,
                      color: AppTheme.crimson,
                      onTap: () => _quickDamage(context, onDamage),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          p.temporaryHp > 0
                              ? '${p.currentHp} / ${p.maxHp} HP + ${p.temporaryHp} THP'
                              : '${p.currentHp} / ${p.maxHp} HP',
                          style: AppTextStyles.lato(
                            color: isDefeated
                                ? Colors.white38
                                : _hpColor(p.hpPercent),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QuickButton(
                      icon: Icons.add,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _quickHeal(context, onHeal),
                    ),
                  ],
                ),
                if (!p.isPlayer && p.monsterIndex.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MonsterAbilitySummary(
                    key: ValueKey(p.monsterIndex),
                    monsterIndex: p.monsterIndex,
                  ),
                  const SizedBox(height: 6),
                  _MonsterDefenseSummaryCard(
                    key: ValueKey('defense_${p.monsterIndex}'),
                    monsterIndex: p.monsterIndex,
                  ),
                ],
                if (_hasStatus(p)) ...[
                  const SizedBox(height: 8),
                  _StatusRow(participant: p),
                ],
                if (p.conditions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: p.conditions
                        .map((c) => _ConditionPill(label: c))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasStatus(EncounterParticipant p) =>
      p.temporaryHp > 0 ||
      p.exhaustionLevel > 0 ||
      p.concentrating ||
      p.reactionUsed ||
      p.legendaryActionsMax > 0 ||
      p.legendaryResistancesMax > 0;

  void _quickDamage(BuildContext context, void Function(int) onDamage) {
    _showQuickInputDialog(
      context,
      title: 'Apply Damage',
      hintText: 'Damage amount',
      confirmLabel: 'Apply',
      confirmColor: AppTheme.crimson,
      onConfirm: onDamage,
    );
  }

  void _quickHeal(BuildContext context, void Function(int) onHeal) {
    _showQuickInputDialog(
      context,
      title: 'Apply Healing',
      hintText: 'Healing amount',
      confirmLabel: 'Heal',
      confirmColor: const Color(0xFF4CAF50),
      onConfirm: onHeal,
    );
  }

  void _showQuickInputDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    required String confirmLabel,
    required Color confirmColor,
    required void Function(int) onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _QuickInputDialog(
        title: title,
        hintText: hintText,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  void _showInitiativeModal(
    BuildContext context,
    int currentInitiative,
    void Function(int) onSet,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _InitiativeEditDialog(
        currentValue: currentInitiative,
        onConfirm: onSet,
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static Color _hpColor(double percent) {
    if (percent > 0.5) return const Color(0xFF4CAF50);
    if (percent > 0.25) return const Color(0xFFFF9800);
    return AppTheme.crimson;
  }
}

class _QuickInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmLabel;
  final Color confirmColor;
  final void Function(int) onConfirm;

  const _QuickInputDialog({
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  State<_QuickInputDialog> createState() => _QuickInputDialogState();
}

class _QuickInputDialogState extends State<_QuickInputDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_ctrl.text) ?? 0;
    Navigator.of(context).pop();
    widget.onConfirm(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.ashGray,
      title:
          Text(widget.title, style: AppTextStyles.cinzel(color: AppTheme.gold)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: widget.confirmColor),
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _InitiativeEditDialog extends StatefulWidget {
  final int currentValue;
  final void Function(int) onConfirm;

  const _InitiativeEditDialog({
    required this.currentValue,
    required this.onConfirm,
  });

  @override
  State<_InitiativeEditDialog> createState() => _InitiativeEditDialogState();
}

class _InitiativeEditDialogState extends State<_InitiativeEditDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.currentValue}');
    _ctrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _ctrl.text.length,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_ctrl.text) ?? widget.currentValue;
    Navigator.of(context).pop();
    widget.onConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.ashGray,
      title: Text(
        'Edit Initiative',
        style: AppTextStyles.cinzel(color: AppTheme.gold),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
        decoration: const InputDecoration(hintText: 'Initiative value'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _MonsterAbilitySummary extends ConsumerWidget {
  final String monsterIndex;

  const _MonsterAbilitySummary({
    required this.monsterIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterAsync = ref.watch(monsterDetailProvider(monsterIndex));

    return monsterAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (monster) {
        final abilities = [
          _AbilityValue.fromMonster(monster, 'STR'),
          _AbilityValue.fromMonster(monster, 'DEX'),
          _AbilityValue.fromMonster(monster, 'CON'),
          _AbilityValue.fromMonster(monster, 'INT'),
          _AbilityValue.fromMonster(monster, 'WIS'),
          _AbilityValue.fromMonster(monster, 'CHA'),
        ];

        return Wrap(
          spacing: 5,
          runSpacing: 5,
          children: abilities
              .map((ability) => _AbilityModifierChip(ability: ability))
              .toList(),
        );
      },
    );
  }
}

class _MonsterDefenseSummaryCard extends ConsumerWidget {
  final String monsterIndex;

  const _MonsterDefenseSummaryCard({
    required this.monsterIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterAsync = ref.watch(monsterDetailProvider(monsterIndex));

    return monsterAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (monster) {
        final defenses = <({String label, List<String> values, Color color})>[];

        if (monster.damageVulnerabilities.isNotEmpty) {
          defenses.add((
            label: 'Vuln',
            values: monster.damageVulnerabilities,
            color: const Color(0xFFFF6B6B),
          ));
        }

        if (monster.damageResistances.isNotEmpty) {
          defenses.add((
            label: 'Resist',
            values: monster.damageResistances,
            color: const Color.fromARGB(255, 190, 65, 34),
          ));
        }

        if (monster.damageImmunities.isNotEmpty) {
          defenses.add((
            label: 'Immune',
            values: monster.damageImmunities,
            color: const Color(0xFF95E1D3),
          ));
        }

        if (defenses.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 5,
          runSpacing: 5,
          children: defenses
              .map((def) => _DefensePill(
                    label: def.label,
                    values: def.values,
                    color: def.color,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _DefensePill extends StatelessWidget {
  final String label;
  final List<String> values;
  final Color color;

  const _DefensePill({
    required this.label,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = values.length == 1
        ? '${label}: ${values.first}'
        : '${label}: ${values.length}';

    return Tooltip(
      message: values.join(', '),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          displayText,
          style: AppTextStyles.lato(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AbilityValue {
  final String label;
  final int score;
  final int? savingThrowBonus;

  const _AbilityValue(
    this.label,
    this.score, {
    this.savingThrowBonus,
  });

  factory _AbilityValue.fromMonster(MonsterDetailDto monster, String label) {
    return _AbilityValue(
      label,
      monster.abilityScoreFor(label),
      savingThrowBonus: monster.savingThrowBonuses[label],
    );
  }

  bool get hasSavingThrow => savingThrowBonus != null;

  int get rawModifier => DiceCalculator.getModifier(score);

  int get displayValue => rawModifier + (savingThrowBonus ?? 0);

  String get modifier {
    final value = displayValue;
    return value >= 0 ? '+$value' : '$value';
  }

  String get tooltip {
    if (!hasSavingThrow) return '$label ability modifier';
    final raw = rawModifier >= 0 ? '+$rawModifier' : '$rawModifier';
    final bonus =
        savingThrowBonus! >= 0 ? '+$savingThrowBonus' : '$savingThrowBonus';
    return 'Saving Throw: $label $modifier ($raw + $bonus)';
  }
}

class _AbilityModifierChip extends StatelessWidget {
  final _AbilityValue ability;

  const _AbilityModifierChip({required this.ability});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: ability.tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: ability.hasSavingThrow
              ? AppTheme.gold.withValues(alpha: 0.12)
              : AppTheme.charcoal.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ability.hasSavingThrow
                ? AppTheme.gold.withValues(alpha: 0.45)
                : Colors.white10,
          ),
        ),
        child: Text(
          '${ability.label} ${ability.modifier}',
          style: AppTextStyles.lato(
            color: ability.hasSavingThrow ? AppTheme.gold : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ColorMarker extends StatelessWidget {
  final Color color;

  const _ColorMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _ColorTagPicker extends StatelessWidget {
  final int selectedColor;
  final void Function(int colorTag) onSelected;

  const _ColorTagPicker({
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ColorChoice(
          label: 'None',
          colorTag: 0,
          selected: selectedColor == 0,
          onSelected: onSelected,
        ),
        for (final colorTag in encounterColorTags)
          _ColorChoice(
            colorTag: colorTag,
            selected: selectedColor == colorTag ||
                (selectedColor == legacyBlackEncounterColorTag &&
                    colorTag == visibleGrayEncounterColorTag),
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final String? label;
  final int colorTag;
  final bool selected;
  final void Function(int colorTag) onSelected;

  const _ColorChoice({
    this.label,
    required this.colorTag,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        colorTag == 0 ? Colors.white38 : encounterColorForTag(colorTag);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onSelected(colorTag),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: label == null ? 34 : 68,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorTag == 0
              ? Colors.white.withValues(alpha: 0.06)
              : color.withValues(alpha: selected ? 0.35 : 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.gold : color.withValues(alpha: 0.7),
            width: selected ? 2 : 1,
          ),
        ),
        child: label == null
            ? Icon(
                selected ? Icons.check : Icons.circle,
                color: selected ? AppTheme.gold : color,
                size: selected ? 17 : 14,
              )
            : Text(
                label!,
                style: AppTextStyles.lato(
                  color: selected ? AppTheme.gold : Colors.white54,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );
  }
}
