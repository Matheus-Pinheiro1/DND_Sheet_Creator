part of 'encounter_screen.dart';

class _ParticipantCard extends StatelessWidget {
  final EncounterParticipant participant;
  final bool isActive;
  final VoidCallback onTap;
  final void Function(int) onDamage;
  final void Function(int) onHeal;

  const _ParticipantCard({
    required this.participant,
    required this.isActive,
    required this.onTap,
    required this.onDamage,
    required this.onHeal,
  });

  @override
  Widget build(BuildContext context) {
    final p = participant;
    final isDefeated = p.isDefeated;
    final tagColor = p.colorTag == 0 ? null : Color(p.colorTag);

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
                    // Initiative badge
                    _InitiativeBadge(
                        initiative: p.initiative, isActive: isActive),
                    const SizedBox(width: 10),
                    // Name + type
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
                                : '${_capitalize(p.type)} • CR ${p.crLabel}',
                            style: AppTextStyles.lato(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // AC badge
                    _AcBadge(ac: p.armorClass),
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
                      onTap: () => _quickDamage(context, p.id, onDamage),
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
                      onTap: () => _quickHeal(context, p.id, onHeal),
                    ),
                  ],
                ),
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
      p.concentrating ||
      p.reactionUsed ||
      p.legendaryActionsMax > 0 ||
      p.legendaryResistancesMax > 0;

  void _quickDamage(
      BuildContext context, String id, void Function(int) onDamage) {
    _showQuickInputDialog(
      context,
      title: 'Apply Damage',
      hintText: 'Damage amount',
      confirmLabel: 'Apply',
      confirmColor: AppTheme.crimson,
      onConfirm: onDamage,
    );
  }

  void _quickHeal(BuildContext context, String id, void Function(int) onHeal) {
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
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(title, style: AppTextStyles.cinzel(color: AppTheme.gold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: hintText),
          onSubmitted: (v) {
            final amount = int.tryParse(v) ?? 0;
            onConfirm(amount);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () {
              final amount = int.tryParse(ctrl.text) ?? 0;
              onConfirm(amount);
              Navigator.pop(ctx);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static Color _hpColor(double percent) {
    if (percent > 0.5) return const Color(0xFF4CAF50);
    if (percent > 0.25) return const Color(0xFFFF9800);
    return AppTheme.crimson;
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
        for (final colorTag in _encounterColorTags)
          _ColorChoice(
            colorTag: colorTag,
            selected: selectedColor == colorTag,
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
    final color = colorTag == 0 ? Colors.white38 : Color(colorTag);

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
