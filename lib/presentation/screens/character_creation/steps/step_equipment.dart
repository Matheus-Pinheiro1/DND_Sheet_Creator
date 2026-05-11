import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/starting_equipment_service.dart';
import '../../../../providers/character_creation_provider.dart';

class StepEquipment extends ConsumerWidget {
  const StepEquipment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final classOptions = StartingEquipmentService.parseOptions(
      StartingEquipmentService.classOptionTexts(state.className),
    );
    final backgroundOptions = StartingEquipmentService.parseOptions(
      state.backgroundEquipmentOptions,
    );
    final selectedClassOption = StartingEquipmentService.optionById(
      classOptions,
      state.classEquipmentChoiceId,
    );
    final selectedBackgroundOption = StartingEquipmentService.optionById(
      backgroundOptions,
      state.backgroundEquipmentChoiceId,
    );
    final totalGold = (selectedClassOption?.gold ?? 0) +
        (selectedBackgroundOption?.gold ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Starting Equipment',
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the equipment package from your class and the package from your background. GP from both packages is added to the sheet.',
          style: AppTextStyles.lato(
            color: Colors.white70,
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        _GoldPreview(totalGold: totalGold),
        const SizedBox(height: 14),
        if (classOptions.isEmpty && backgroundOptions.isEmpty)
          const _NoEquipmentOptions()
        else ...[
          if (classOptions.isNotEmpty) ...[
            _EquipmentChoiceSection(
              title: state.classDisplayName.isEmpty
                  ? 'Class Equipment'
                  : '${state.classDisplayName} Equipment',
              options: classOptions,
              selectedId: state.classEquipmentChoiceId,
              onChanged: notifier.setClassEquipmentChoice,
            ),
            const SizedBox(height: 14),
          ],
          if (backgroundOptions.isNotEmpty)
            _EquipmentChoiceSection(
              title: state.backgroundName.isEmpty
                  ? 'Background Equipment'
                  : '${state.backgroundName} Equipment',
              options: backgroundOptions,
              selectedId: state.backgroundEquipmentChoiceId,
              onChanged: notifier.setBackgroundEquipmentChoice,
            ),
        ],
      ],
    );
  }
}

class _GoldPreview extends StatelessWidget {
  final int totalGold;

  const _GoldPreview({required this.totalGold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined, color: AppTheme.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Starting Gold',
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$totalGold GP',
            style: AppTextStyles.cinzel(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentChoiceSection extends StatelessWidget {
  final String title;
  final List<StartingEquipmentOption> options;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _EquipmentChoiceSection({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.30)),
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
          const SizedBox(height: 10),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EquipmentOptionTile(
                option: option,
                isSelected: selectedId == option.id,
                onTap: () => onChanged(option.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentOptionTile extends StatelessWidget {
  final StartingEquipmentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _EquipmentOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.crimson.withValues(alpha: 0.24)
                : AppTheme.charcoal.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.gold : Colors.white12,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.gold : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: AppTextStyles.cinzel(
                              color: isSelected ? AppTheme.gold : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${option.gold} GP',
                          style: AppTextStyles.lato(
                            color: AppTheme.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (option.items.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        option.items.join(', '),
                        style: AppTextStyles.lato(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoEquipmentOptions extends StatelessWidget {
  const _NoEquipmentOptions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        'No starting equipment options were found for this class/background combination.',
        style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}
