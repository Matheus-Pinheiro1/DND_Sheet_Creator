import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/services/druid_choice_service.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';

class DruidClassChoices extends ConsumerWidget {
  const DruidClassChoices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedOrder = DruidChoiceService.selectedPrimalOrder(
      state.levelAdvancements,
    );
    final selectedFury = DruidChoiceService.selectedElementalFury(
      state.levelAdvancements,
    );
    final selectedLand = DruidChoiceService.selectedLandType(
      state.levelAdvancements,
    );
    final landSpells = DruidChoiceService.landSpellIds(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
      entries: state.levelAdvancements,
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
            'Druid Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your Primal Order. At Druid level 7, choose your Elemental Fury option.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Primal Order',
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
            children:
                DruidChoiceService.primalOrderOptions.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: selectedOrder == entry.key,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => notifier.setDruidPrimalOrder(entry.key),
              );
            }).toList(),
          ),
          if (selectedOrder == DruidChoiceService.magicianOrder) ...[
            const SizedBox(height: 8),
            Text(
              'Choose the extra Druid cantrip in the Spells step. Arcana and Nature also receive your Wisdom modifier, minimum +1.',
              style: AppTextStyles.lato(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (selectedOrder == DruidChoiceService.wardenOrder) ...[
            const SizedBox(height: 8),
            Text(
              'Martial weapon and Medium armor proficiency will be added automatically.',
              style: AppTextStyles.lato(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (DruidChoiceService.isLand(
            className: state.className,
            subclass: state.subclass,
            level: state.level,
          )) ...[
            const SizedBox(height: 16),
            Text(
              'Circle of the Land',
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
              children: DruidChoiceService.landTypeOptions.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selectedLand == entry.key,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => notifier.setDruidLandType(entry.key),
                );
              }).toList(),
            ),
            if (selectedLand != null) ...[
              const SizedBox(height: 8),
              Text(
                landSpells.isEmpty
                    ? 'Choose a land type to add its Circle Spells.'
                    : 'Circle Spells: ${landSpells.map(DruidChoiceService.spellLabel).join(', ')}.',
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ],
          if (state.level >= 7) ...[
            const SizedBox(height: 16),
            Text(
              'Elemental Fury',
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
              children:
                  DruidChoiceService.elementalFuryOptions.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selectedFury == entry.key,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => notifier.setDruidElementalFury(entry.key),
                );
              }).toList(),
            ),
            if (selectedFury == DruidChoiceService.primalStrike) ...[
              const SizedBox(height: 8),
              Text(
                'Primal Strike damage is ${DruidChoiceService.elementalFuryDamageDie(state.level)} at this level.',
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
