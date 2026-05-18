import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/local/feats_data.dart';
import '../../../../data/models/feat_model.dart';
import '../../../../data/services/level_advancement_service.dart';
import '../../../../data/services/progression_service.dart';
import '../../../../providers/character_creation_provider.dart';

part 'step_advancements_picker_sheet.dart';
part 'step_advancements_widgets.dart';

class StepAdvancements extends ConsumerWidget {
  const StepAdvancements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);

    if (state.className.isEmpty) {
      return const _InfoMessage(
        emoji: '⚠️',
        title: 'No class selected',
        subtitle: 'Go back and choose your class first.',
      );
    }

    final advancementLevels = LevelAdvancementService.availableLevels(
      state.className,
      state.level,
    );

    if (advancementLevels.isEmpty) {
      return const _InfoMessage(
        emoji: '⚔️',
        title: 'No Advancements Yet',
        subtitle:
            'Reach level 4 to unlock your first Ability Score Improvement or Feat.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech_outlined,
                      color: AppTheme.gold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Level Advancements',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'At levels ${advancementLevels.join(', ')}, you may improve two ability scores by 1 each, increase one by 2, or take a Feat.',
                style: AppTextStyles.lato(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...advancementLevels.map((advLevel) {
          final filtered = state.levelAdvancements.where((e) {
            if (!e.startsWith('level:')) return false;
            final parts = e.split(':');
            return parts.length >= 4 && int.tryParse(parts[1]) == advLevel;
          });
          final entry = filtered.isEmpty ? null : filtered.first;

          return _AdvancementSlot(advLevel: advLevel, entry: entry);
        }),
      ],
    );
  }
}
