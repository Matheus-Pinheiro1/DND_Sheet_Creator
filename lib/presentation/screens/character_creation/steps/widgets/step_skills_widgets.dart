part of '../step_skills.dart';

class _SkillSummaryCard extends StatelessWidget {
  final int proficiencyBonus;
  final int backgroundCount;
  final int chosenCount;
  final int originCount;

  const _SkillSummaryCard({
    required this.proficiencyBonus,
    required this.backgroundCount,
    required this.chosenCount,
    required this.originCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proficiency Bonus: +$proficiencyBonus',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (backgroundCount > 0)
            Text(
              '$backgroundCount skill${backgroundCount > 1 ? 's' : ''} from background',
              style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
            ),
          Text(
            '$chosenCount class skill${chosenCount != 1 ? 's' : ''} selected',
            style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          ),
          if (originCount > 0)
            Text(
              '$originCount skill${originCount > 1 ? 's' : ''} from Origin Feat',
              style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final String index;
  final String name;
  final String ability;
  final int total;
  final bool isProficient;
  final bool isFromBackground;
  final bool isFromOriginFeat;
  final bool isFromSpeciesChoice;
  final bool isFromClassChoice;
  final VoidCallback? onToggle;

  const _SkillTile({
    required this.index,
    required this.name,
    required this.ability,
    required this.total,
    required this.isProficient,
    required this.isFromBackground,
    required this.isFromOriginFeat,
    required this.isFromSpeciesChoice,
    required this.isFromClassChoice,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProficient
                ? (isFromBackground ||
                        isFromOriginFeat ||
                        isFromSpeciesChoice ||
                        isFromClassChoice
                    ? AppTheme.gold
                    : AppTheme.crimson)
                : Colors.transparent,
            border: Border.all(
              color: isProficient
                  ? (isFromBackground ||
                          isFromOriginFeat ||
                          isFromSpeciesChoice ||
                          isFromClassChoice
                      ? AppTheme.gold
                      : AppTheme.crimson)
                  : Colors.white24,
              width: 1.5,
            ),
          ),
          child: isProficient
              ? Icon(
                  isFromBackground ||
                          isFromOriginFeat ||
                          isFromSpeciesChoice ||
                          isFromClassChoice
                      ? Icons.lock
                      : Icons.check,
                  size: 12,
                  color: isFromBackground ||
                          isFromOriginFeat ||
                          isFromSpeciesChoice ||
                          isFromClassChoice
                      ? AppTheme.charcoal
                      : Colors.white,
                )
              : null,
        ),
      ),
      title: Row(
        children: [
          Text(
            name,
            style: AppTextStyles.lato(
              color: isProficient ? Colors.white : Colors.white60,
              fontSize: 14,
              fontWeight: isProficient ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isFromBackground) ...[
            const SizedBox(width: 6),
            const _SourceBadge(label: 'BG'),
          ],
          if (isFromOriginFeat) ...[
            const SizedBox(width: 6),
            const _SourceBadge(label: 'FEAT'),
          ],
          if (isFromSpeciesChoice) ...[
            const SizedBox(width: 6),
            const _SourceBadge(label: 'SPECIES'),
          ],
          if (isFromClassChoice) ...[
            const SizedBox(width: 6),
            const _SourceBadge(label: 'CLASS'),
          ],
        ],
      ),
      subtitle: Text(
        ability,
        style: AppTextStyles.lato(color: Colors.white30, fontSize: 10),
      ),
      trailing: Text(
        total >= 0 ? '+$total' : '$total',
        style: AppTextStyles.cinzel(
          color: isProficient ? AppTheme.gold : Colors.white38,
          fontSize: 15,
          fontWeight: isProficient ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String label;
  const _SourceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.gold,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BarbarianPrimalKnowledgeCard extends StatelessWidget {
  final List<_ChoiceOption> options;
  final String? selectedValue;
  final bool isSelectionValid;
  final ValueChanged<String> onChanged;

  const _BarbarianPrimalKnowledgeCard({
    required this.options,
    required this.selectedValue,
    required this.isSelectionValid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final complete =
        (selectedValue != null && isSelectionValid) || options.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primal Knowledge',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose one additional Barbarian skill proficiency. While raging, Primal Knowledge can also let some checks use Strength.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            options.isEmpty
                ? 'No eligible skill left'
                : complete
                    ? '1 / 1 selected'
                    : '0 / 1 selected',
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text(
              'All eligible Barbarian skills are already proficient.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selectedValue == option.value,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => onChanged(option.value),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RangerExpertiseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ChoiceOption> options;
  final List<String> selectedValues;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _RangerExpertiseCard({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValues,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final complete = selectedValues.length == maxSelections;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedValues.length} / $maxSelections selected',
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text(
              'Choose a skill proficiency above before selecting Expertise here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final selected = selectedValues.contains(option.value);
                final disabled =
                    !selected && selectedValues.length >= maxSelections;

                return FilterChip(
                  label: Text(option.label),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: disabled
                      ? null
                      : (value) {
                          final next = List<String>.from(selectedValues);
                          if (value) {
                            next.add(option.value);
                          } else {
                            next.remove(option.value);
                          }
                          onChanged(next);
                        },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RangerLanguageCard extends StatelessWidget {
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const _RangerLanguageCard({
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const maxSelections = RangerChoiceService.deftExplorerLanguageCount;
    final complete = selectedValues.length == maxSelections;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deft Explorer Languages',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose 2 languages granted by Deft Explorer.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedValues.length} / $maxSelections selected',
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RangerChoiceService.languageOptions.map((language) {
              final selected = selectedValues.contains(language);
              final disabled =
                  !selected && selectedValues.length >= maxSelections;

              return FilterChip(
                label: Text(language),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedValues);
                        if (value) {
                          next.add(language);
                        } else {
                          next.remove(language);
                        }
                        onChanged(next);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RogueExpertiseCard extends StatelessWidget {
  final int rogueLevel;
  final List<_ChoiceOption> options;
  final List<String> selectedValues;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _RogueExpertiseCard({
    required this.rogueLevel,
    required this.options,
    required this.selectedValues,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final complete = selectedValues.length == maxSelections;
    final title =
        rogueLevel == 1 ? 'Expertise' : 'Expertise (Level $rogueLevel)';
    final subtitle = rogueLevel == 1
        ? 'Choose 2 of your skill proficiencies. These skills gain Expertise.'
        : 'Choose 2 more of your skill proficiencies. These skills gain Expertise.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedValues.length} / $maxSelections selected',
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            Text(
              'Choose more skill proficiencies above before selecting Expertise here.',
              style: AppTextStyles.lato(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.4,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final selected = selectedValues.contains(option.value);
                final disabled =
                    !selected && selectedValues.length >= maxSelections;

                return FilterChip(
                  label: Text(option.label),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: disabled
                      ? null
                      : (value) {
                          final next = List<String>.from(selectedValues);
                          if (value) {
                            next.add(option.value);
                          } else {
                            next.remove(option.value);
                          }
                          onChanged(next);
                        },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _OriginChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String selectedText;
  final List<_ChoiceOption> options;
  final List<String> selectedValues;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _OriginChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selectedText,
    required this.options,
    required this.selectedValues,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final complete = selectedValues.length == maxSelections;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Origin Feat',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedText,
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = selectedValues.contains(option.value);
              final disabled =
                  !selected && selectedValues.length >= maxSelections;

              return FilterChip(
                label: Text(option.label),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedValues);
                        if (value) {
                          next.add(option.value);
                        } else {
                          next.remove(option.value);
                        }
                        onChanged(next);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ClassChoicePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String selectedText;
  final List<_ChoiceOption> options;
  final List<String> selectedValues;
  final int maxSelections;
  final ValueChanged<List<String>> onChanged;

  const _ClassChoicePanel({
    required this.title,
    required this.subtitle,
    required this.selectedText,
    required this.options,
    required this.selectedValues,
    required this.maxSelections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final complete = selectedValues.length == maxSelections;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: complete
              ? Colors.greenAccent.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedText,
            style: AppTextStyles.lato(
              color: complete ? Colors.greenAccent : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = selectedValues.contains(option.value);
              final disabled =
                  !selected && selectedValues.length >= maxSelections;

              return FilterChip(
                label: Text(option.label),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedValues);
                        if (value) {
                          next.add(option.value);
                        } else {
                          next.remove(option.value);
                        }
                        onChanged(next);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceOption {
  final String value;
  final String label;

  const _ChoiceOption({required this.value, required this.label});
}
