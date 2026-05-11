import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/services/warlock_choice_service.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';

class WarlockClassChoices extends ConsumerWidget {
  const WarlockClassChoices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selected = WarlockChoiceService.selectedInvocations(
      state.levelAdvancements,
    );
    final required = WarlockChoiceService.invocationCountForLevel(state.level);

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
            'Warlock Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your Eldritch Invocations. Pact of the Tome unlocks its cantrip and ritual spell choices in the Spells step.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Eldritch Invocations - ${selected.length} / $required',
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
            children: WarlockChoiceService.invocationIds.map((invocationId) {
              final isSelected = selected.contains(invocationId);
              final qualifies = WarlockChoiceService.qualifiesForInvocation(
                invocationId: invocationId,
                level: state.level,
                selectedInvocationIds: selected,
              );
              final disabled =
                  !isSelected && (selected.length >= required || !qualifies);

              return FilterChip(
                label: Text(WarlockChoiceService.invocationLabel(invocationId)),
                selected: isSelected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selected);
                        if (value) {
                          next.add(invocationId);
                        } else {
                          next.remove(invocationId);
                        }
                        notifier.setWarlockInvocations(next);
                      },
              );
            }).toList(),
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...selected.map((invocationId) {
              final prerequisite =
                  WarlockChoiceService.invocationPrerequisite(invocationId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${WarlockChoiceService.invocationLabel(invocationId)}'
                  '${prerequisite.isEmpty ? '' : ' - $prerequisite'}: '
                  '${WarlockChoiceService.invocationSummary(invocationId)}',
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
      ),
    );
  }
}
