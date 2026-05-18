part of 'encounter_screen.dart';

class _InitiativeBadge extends StatelessWidget {
  final int initiative;
  final bool isActive;

  const _InitiativeBadge({required this.initiative, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            isActive ? AppTheme.gold.withValues(alpha: 0.2) : AppTheme.ashGray,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.gold : Colors.white24,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          '$initiative',
          style: AppTextStyles.cinzel(
            color: isActive ? AppTheme.gold : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AcBadge extends StatelessWidget {
  final int ac;

  const _AcBadge({required this.ac});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.shield_outlined, size: 14, color: Colors.white38),
        Text(
          '$ac',
          style: AppTextStyles.lato(
              color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _HpBar extends StatelessWidget {
  final EncounterParticipant participant;

  const _HpBar({required this.participant});

  @override
  Widget build(BuildContext context) {
    final percent = participant.hpPercent;
    final color = percent > 0.5
        ? const Color(0xFF4CAF50)
        : percent > 0.25
            ? const Color(0xFFFF9800)
            : AppTheme.crimson;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: percent,
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 6,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final EncounterParticipant participant;

  const _StatusRow({required this.participant});

  @override
  Widget build(BuildContext context) {
    final p = participant;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (p.temporaryHp > 0)
          _StatusPill(label: 'Temp HP ${p.temporaryHp}', color: Colors.cyan),
        if (p.exhaustionLevel > 0)
          _StatusPill(
            label: 'Exhaustion ${p.exhaustionLevel}',
            color: AppTheme.crimson,
          ),
        if (p.concentrating)
          const _StatusPill(label: 'Concentration', color: Color(0xFF7B68EE)),
        if (p.reactionUsed)
          const _StatusPill(label: 'Reaction Used', color: Color(0xFFFF9800)),
        if (p.legendaryActionsMax > 0)
          _StatusPill(
            label: 'LA ${p.legendaryActionsRemaining}/${p.legendaryActionsMax}',
            color: p.legendaryActionsRemaining > 0
                ? AppTheme.gold
                : Colors.white30,
          ),
        if (p.legendaryResistancesMax > 0)
          _StatusPill(
            label:
                'LR ${p.legendaryResistancesRemaining}/${p.legendaryResistancesMax}',
            color: p.legendaryResistancesRemaining > 0
                ? const Color(0xFF20B2AA)
                : Colors.white30,
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(label, style: AppTextStyles.lato(color: color, fontSize: 11)),
    );
  }
}

class _ConditionPill extends StatelessWidget {
  final String label;

  const _ConditionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _conditionTooltip(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.crimson.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: AppTextStyles.lato(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

const _conditionDescriptions = <String, String>{
  'Blinded':
      'Cannot see; attacks against it have advantage, and its attacks have disadvantage.',
  'Charmed':
      'Cannot attack or target the charmer; the charmer has advantage on social checks.',
  'Deafened':
      'Cannot hear and automatically fails checks that require hearing.',
  'Exhaustion':
      'Suffers stacking exhaustion penalties until the condition is reduced.',
  'Frightened':
      'Disadvantage while the source is in sight; cannot willingly move closer.',
  'Grappled': 'Speed is 0 until the grapple ends.',
  'Incapacitated': 'Cannot take actions or reactions.',
  'Invisible':
      'Cannot be seen without special senses; attacks against it have disadvantage.',
  'Paralyzed':
      'Incapacitated, cannot move or speak, and nearby hits can become critical hits.',
  'Petrified':
      'Transformed and incapacitated; resistant to damage and unaware of surroundings.',
  'Poisoned': 'Disadvantage on attack rolls and ability checks.',
  'Prone':
      'Only crawls unless it stands; nearby attacks have advantage, ranged attacks disadvantage.',
  'Restrained':
      'Speed is 0; attacks against it have advantage, and its attacks have disadvantage.',
  'Stunned':
      'Incapacitated, cannot move, speaks falteringly, and fails STR/DEX saves.',
  'Unconscious':
      'Incapacitated, drops held items, falls prone, and nearby hits can become critical hits.',
};

String _conditionTooltip(String label) =>
    _conditionDescriptions[label] ?? label;

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SheetSection(
      {required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.ashGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final Color iconColor;
  final VoidCallback onConfirm;
  final Color confirmColor;
  final String confirmLabel;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.iconColor,
    required this.onConfirm,
    required this.confirmColor,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(prefixIcon, color: iconColor, size: 18),
            isDense: true,
          ),
          onSubmitted: (_) => onConfirm(),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: onConfirm,
            child: Text(confirmLabel,
                style: AppTextStyles.lato(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onToggle;

  const _ToggleTile({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              active ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? activeColor : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: active ? activeColor : Colors.white38),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.lato(
                  color: active ? activeColor : Colors.white54,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhaustionControl extends StatelessWidget {
  final int level;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ExhaustionControl({
    required this.level,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          'Exhaustion has 6 levels. Apply -2 per level to d20 tests; level 6 is death.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: level > 0
              ? AppTheme.crimson.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: level > 0 ? AppTheme.crimson : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Exhaustion',
                style: AppTextStyles.lato(
                  color: level > 0 ? AppTheme.crimson : Colors.white54,
                  fontSize: 12,
                  fontWeight: level > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Decrease exhaustion',
              onPressed: level > 0 ? onDecrease : null,
              icon: const Icon(Icons.remove, size: 16),
            ),
            SizedBox(
              width: 52,
              child: Text(
                '$level / 6',
                textAlign: TextAlign.center,
                style: AppTextStyles.cinzel(
                  color: level > 0 ? AppTheme.crimson : Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Increase exhaustion',
              onPressed: level < 6 ? onIncrease : null,
              icon: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendaryCounter extends StatelessWidget {
  final String label;
  final int used;
  final int max;
  final VoidCallback onUse;
  final VoidCallback onReset;

  const _LegendaryCounter({
    required this.label,
    required this.used,
    required this.max,
    required this.onUse,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (max - used).clamp(0, max);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      AppTextStyles.lato(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: List.generate(max, (i) {
                  final filled = i < remaining;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: filled
                            ? AppTheme.gold.withValues(alpha: 0.7)
                            : Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: filled ? AppTheme.gold : Colors.white24,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          color: remaining > 0 ? AppTheme.crimson : Colors.white24,
          onPressed: remaining > 0 ? onUse : null,
          tooltip: 'Use',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          color: Colors.white38,
          onPressed: onReset,
          tooltip: 'Reset',
        ),
      ],
    );
  }
}
