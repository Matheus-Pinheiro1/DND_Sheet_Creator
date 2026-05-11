import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/services/sorcerer_choice_service.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';

class SorcererClassChoices extends ConsumerWidget {
  const SorcererClassChoices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final unlockedLevels =
        SorcererChoiceService.unlockedMetamagicLevels(state.level);
    final needsDraconicAffinity = SorcererChoiceService.needsDraconicAffinity(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final selectedDraconicAffinity =
        SorcererChoiceService.selectedDraconicAffinity(
      state.levelAdvancements,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sorcerer Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.level < 2
                ? 'Metamagic choices unlock at Sorcerer level 2.'
                : 'Choose Metamagic options as they unlock at Sorcerer levels 2, 10, and 17.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          for (final sorcererLevel in unlockedLevels) ...[
            const SizedBox(height: 14),
            _MetamagicChoiceGroup(
              sorcererLevel: sorcererLevel,
              onChanged: (choices) => notifier.setSorcererMetamagicChoices(
                sorcererLevel: sorcererLevel,
                optionIds: choices,
              ),
            ),
          ],
          if (needsDraconicAffinity) ...[
            const SizedBox(height: 16),
            Text(
              'Elemental Affinity',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SorcererChoiceService.draconicAffinityOptions.entries
                  .map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selectedDraconicAffinity == entry.key,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) =>
                      notifier.setSorcererDraconicAffinity(entry.key),
                );
              }).toList(),
            ),
            if (selectedDraconicAffinity != null) ...[
              const SizedBox(height: 8),
              Text(
                '${SorcererChoiceService.draconicAffinityLabel(selectedDraconicAffinity)} resistance is added by Elemental Affinity, and spells of that damage type add your Charisma modifier to one damage roll.',
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MetamagicChoiceGroup extends ConsumerWidget {
  final int sorcererLevel;
  final ValueChanged<List<String>> onChanged;

  const _MetamagicChoiceGroup({
    required this.sorcererLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final selected = SorcererChoiceService.selectedMetamagicOptions(
      state.levelAdvancements,
      sorcererLevel: sorcererLevel,
    );
    final selectedElsewhere = <String>{};
    for (final otherLevel
        in SorcererChoiceService.unlockedMetamagicLevels(state.level)) {
      if (otherLevel == sorcererLevel) continue;
      selectedElsewhere.addAll(
        SorcererChoiceService.selectedMetamagicOptions(
          state.levelAdvancements,
          sorcererLevel: otherLevel,
        ),
      );
    }
    final required = SorcererChoiceService.requiredMetamagicSelectionsForLevel(
      sorcererLevel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metamagic level $sorcererLevel - ${selected.length} / $required',
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SorcererChoiceService.metamagicOptionIds.map((optionId) {
            final isSelected = selected.contains(optionId);
            final alreadyPickedElsewhere = selectedElsewhere.contains(optionId);
            final selectionFull = selected.length >= required;
            final disabled =
                !isSelected && (selectionFull || alreadyPickedElsewhere);

            return FilterChip(
              label: Text(SorcererChoiceService.metamagicLabel(optionId)),
              selected: isSelected,
              selectedColor: AppTheme.crimson,
              onSelected: disabled
                  ? null
                  : (value) {
                      final next = List<String>.from(selected);
                      if (value) {
                        next.add(optionId);
                      } else {
                        next.remove(optionId);
                      }
                      onChanged(next);
                    },
            );
          }).toList(),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...selected.map((optionId) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${SorcererChoiceService.metamagicLabel(optionId)} '
                '(${SorcererChoiceService.metamagicCostLabel(optionId)}): '
                '${SorcererChoiceService.metamagicSummary(optionId)}',
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
