import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/data/remote/race_dto.dart';
import 'package:dnd_character_sheet/data/models/custom_race_model.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';
import 'package:dnd_character_sheet/providers/custom_options_providers.dart';
import 'package:dnd_character_sheet/presentation/screens/custom_options/custom_race_screen.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/dialogs/context_info_dialog.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';

part 'step_race_custom_widgets.dart';
part 'step_race_official_widgets.dart';
part 'step_race_shared_widgets.dart';

class StepRace extends ConsumerWidget {
  const StepRace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final racesAsync = ref.watch(racesProvider);
    final customRaces = ref.watch(customRacesProvider);
    final state = ref.watch(creationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitleWithHelp(
          title: 'Species',
          helpTitle: 'Choosing a Species',
          helpBody:
              'Species sets your movement speed, languages, and species traits. Some 2024 species also ask you to choose a built-in option such as a Draconic Ancestry or Giant Ancestry. Pick the species first, then choose its internal option if one appears below the card.',
        ),
        if (customRaces.isNotEmpty) ...[
          const _SectionHeader('🎨 Homebrew Species'),
          ...customRaces.map((race) => _CustomRaceCard(
                race: race,
                isSelected:
                    _selectedBaseRaceId(state.race) == 'custom_${race.id}',
                onTap: () => ref.read(creationProvider.notifier).setRace(
                      race: 'custom_${race.id}',
                      raceName: race.name,
                      speed: race.speed,
                      languages: race.languages,
                    ),
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CustomRaceScreen(existing: race),
                  ),
                ),
                onDelete: () => _confirmDelete(context, ref, race),
              )),
          const SizedBox(height: 8),
        ],
        _CreateCustomButton(
          label: 'Create Homebrew Species',
          icon: Icons.add,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CustomRaceScreen(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OFFICIAL 2024 SPECIES',
                style: AppTextStyles.lato(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ]),
        ),
        racesAsync.when(
          loading: () => Column(children: [
            const SizedBox(height: 32),
            const LoadingDragon(label: 'Loading...'),
            const SizedBox(height: 12),
            Text(
              'Loading species from your local 2024 catalog...',
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 13),
            ),
          ]),
          error: (e, _) => _ErrorCard(
            message: 'Failed to load official species.',
            onRetry: () => ref.invalidate(racesProvider),
          ),
          data: (races) => Column(
            children: races
                .map(
                  (race) => _OfficialRaceCard(
                    race: race,
                    isSelected: _selectedBaseRaceId(state.race) == race.index,
                    selectedOptionIds: _selectedOptionIds(state.race),
                    selectedExtraLanguage:
                        _selectedExtraLanguage(state.languages),
                    onSelectExtraLanguage: (language) {
                      ref
                          .read(creationProvider.notifier)
                          .setSpeciesExtraLanguage(language);
                    },
                    onTap: () {
                      final firstGroup = race.optionGroups.isNotEmpty
                          ? race.optionGroups.first
                          : null;
                      final firstOption =
                          firstGroup != null && firstGroup.options.isNotEmpty
                              ? firstGroup.options.first
                              : null;
                      if (firstGroup != null && firstOption != null) {
                        ref.read(creationProvider.notifier).setSpeciesOption(
                              baseRace: race.index,
                              baseRaceName: race.name,
                              optionGroupId: firstGroup.id,
                              optionId: firstOption.id,
                              optionName: firstOption.name,
                              speed: race.speed,
                              languages: race.languages,
                            );
                        return;
                      }
                      ref.read(creationProvider.notifier).setRace(
                            race: race.index,
                            raceName: race.name,
                            speed: race.speed,
                            languages: race.languages,
                          );
                    },
                    onSelectOption: (group, option) {
                      ref.read(creationProvider.notifier).setSpeciesOption(
                            baseRace: race.index,
                            baseRaceName: race.name,
                            optionGroupId: group.id,
                            optionId: option.id,
                            optionName: option.name,
                            speed: race.speed,
                            languages: race.languages,
                          );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static String _selectedBaseRaceId(String raceValue) {
    if (!raceValue.contains('::')) return raceValue;
    return raceValue.split('::').first;
  }

  static List<String> _selectedOptionIds(String raceValue) {
    final parts = raceValue.split('::');
    if (parts.length < 3) return const [];
    return parts.skip(1).toList();
  }

  static String _selectedExtraLanguage(List<String> languages) {
    for (final language in languages) {
      final normalized = language.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      if (normalized == 'common') continue;
      if (normalized.contains('extra language')) continue;
      if (normalized.contains('language of your choice')) continue;
      return language;
    }
    return '';
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomRaceModel race,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Delete ${race.name}?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          'This homebrew species will be permanently deleted.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customRacesProvider.notifier).delete(race.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
