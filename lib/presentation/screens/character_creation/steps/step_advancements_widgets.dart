part of 'step_advancements.dart';

class _AdvancementSlot extends ConsumerWidget {
  final int advLevel;
  final String? entry;

  const _AdvancementSlot({required this.advLevel, this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = entry != null;
    final label = isSelected
        ? LevelAdvancementService.formatEntry(entry!)
        : 'Tap to choose ASI or Feat';

    return GestureDetector(
      onTap: () => _openPicker(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.crimson.withValues(alpha: 0.15)
              : AppTheme.ashGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $advLevel',
                    style: AppTextStyles.cinzel(
                      color: isSelected ? AppTheme.gold : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTextStyles.lato(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.edit_outlined : Icons.add_circle_outline,
              color: isSelected ? AppTheme.gold : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(creationProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AdvancementPickerSheet(
        advLevel: advLevel,
        currentEntry: entry,
        state: state,
      ),
    );
  }
}

class _FeatTile extends StatelessWidget {
  final FeatModel feat;
  final bool isSelected;
  final bool isMagicInitiate;
  final String? selectedAbility;
  final List<String> availableAbilities;
  final bool Function(String ability) isAbilityAvailable;
  final VoidCallback onTap;
  final ValueChanged<String?> onAbilitySelected;

  const _FeatTile({
    required this.feat,
    required this.isSelected,
    required this.isMagicInitiate,
    this.selectedAbility,
    required this.availableAbilities,
    required this.isAbilityAvailable,
    required this.onTap,
    required this.onAbilitySelected,
  });

  static const _abilityLabels = {
    'str': 'STR',
    'dex': 'DEX',
    'con': 'CON',
    'int': 'INT',
    'wis': 'WIS',
    'cha': 'CHA',
  };

  @override
  Widget build(BuildContext context) {
    final hasAbilityChoice = availableAbilities.isNotEmpty;
    final hasAvailableAbility = availableAbilities.any(isAbilityAvailable);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.crimson.withValues(alpha: 0.18)
            : AppTheme.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.gold : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: onTap,
            title: Text(
              feat.name,
              style: AppTextStyles.cinzel(
                color: isSelected ? AppTheme.gold : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.gold : Colors.white24,
              size: 20,
            ),
          ),
          if (isSelected && !isMagicInitiate && hasAbilityChoice) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose the ability this feat increases.',
                    style: AppTextStyles.lato(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: availableAbilities.map((ability) {
                      final enabled = isAbilityAvailable(ability);
                      return ChoiceChip(
                        label: Text(
                          _abilityLabels[ability] ?? ability.toUpperCase(),
                        ),
                        selected: selectedAbility == ability,
                        selectedColor: AppTheme.crimson,
                        onSelected:
                            enabled ? (_) => onAbilitySelected(ability) : null,
                        labelStyle: AppTextStyles.lato(
                          fontSize: 11,
                          color: enabled ? null : Colors.white38,
                        ),
                      );
                    }).toList(),
                  ),
                  if (!hasAvailableAbility) ...[
                    const SizedBox(height: 8),
                    Text(
                      'All allowed abilities are already at the cap for this level.',
                      style: AppTextStyles.lato(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _InfoMessage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.cinzel(color: Colors.white54, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
