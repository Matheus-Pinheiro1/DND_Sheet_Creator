import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/local/granted_spells_2024.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../data/remote/spell_dto.dart';
import '../../../../data/services/artificer_choice_service.dart';
import '../../../../data/services/bard_choice_service.dart';
import '../../../../data/services/druid_choice_service.dart';
import '../../../../data/services/fighter_choice_service.dart';
import '../../../../data/services/paladin_choice_service.dart';
import '../../../../data/services/progression_service.dart';
import '../../../../data/services/ranger_choice_service.dart';
import '../../../../data/services/rogue_choice_service.dart';
import '../../../../data/services/warlock_choice_service.dart';
import '../../../../data/services/wizard_choice_service.dart';
import '../../../../providers/character_creation_provider.dart';
import '../../../../providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';
part 'widgets/step_spells_widgets.dart';
part 'widgets/step_spells_fighter_choices.dart';
part 'widgets/step_spells_rogue_choices.dart';
part 'widgets/step_spells_warlock_choices.dart';
part 'helpers/step_spells_helpers.dart';
part 'helpers/step_spells_species_cleric_helpers.dart';
part 'helpers/step_spells_wizard_helpers.dart';
part 'helpers/step_spells_class_extra_helpers.dart';
part 'helpers/step_spells_origin_helpers.dart';
part 'helpers/step_spells_class_picker_helpers.dart';

class StepSpells extends ConsumerStatefulWidget {
  const StepSpells({super.key});

  @override
  ConsumerState<StepSpells> createState() => _StepSpellsState();
}

class _StepSpellsState extends ConsumerState<StepSpells> {
  int _selectedLevel = 0;
  String _searchQuery = '';
  int _originSelectedLevel = 0;
  String _originSearchQuery = '';
  int _speciesOriginSelectedLevel = 0;
  String _speciesOriginSearchQuery = '';

  static const _nonCasterClasses = {
    'barbarian',
    'fighter',
    'monk',
    'rogue',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(creationProvider);
    final hasOriginMagic =
        ProgressionService.isMagicInitiateId(state.backgroundFeatId);
    final originList = hasOriginMagic
        ? ProgressionService.magicInitiateListFromId(state.backgroundFeatId)
        : '';
    final isHumanSpecies = _selectedBaseRaceId(state.race) == 'human';
    final hasSpeciesOriginMagic = isHumanSpecies &&
        ProgressionService.isMagicInitiateId(state.speciesOriginFeatId);
    final speciesOriginList = hasSpeciesOriginMagic
        ? ProgressionService.magicInitiateListFromId(state.speciesOriginFeatId)
        : '';
    final needsRogueArcaneTrickster = RogueChoiceService.isArcaneTrickster(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final needsFighterEldritchKnight = FighterChoiceService.isEldritchKnight(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final isNonCaster = _nonCasterClasses.contains(state.className) &&
        !needsRogueArcaneTrickster &&
        !needsFighterEldritchKnight;

    if (state.className.isEmpty && !hasOriginMagic && !hasSpeciesOriginMagic) {
      return const _InfoMessage(
        emoji: '⚠️',
        title: 'No class selected',
        subtitle: 'Go back and choose your class first.',
      );
    }

    final classRules = ProgressionService.getSpellLimitsFor(
      className: state.className,
      level: state.level,
      spellcastingModifier: _spellcastingModifier(state),
    );

    final needsBardMagicalSecrets = BardChoiceService.hasMagicalSecrets(
      className: state.className,
      level: state.level,
    );
    final classSpellsAsync = state.className.isEmpty ||
            isNonCaster ||
            needsRogueArcaneTrickster ||
            needsFighterEldritchKnight
        ? null
        : needsBardMagicalSecrets
            ? ref.watch(allSpellsProvider)
            : ref.watch(classSpellsProvider(state.className));
    final originSpellsAsync =
        hasOriginMagic ? ref.watch(classSpellsProvider(originList)) : null;
    final speciesOriginSpellsAsync = hasSpeciesOriginMagic
        ? ref.watch(classSpellsProvider(speciesOriginList))
        : null;
    final needsSpeciesSpellAbility = _needsSpeciesSpellAbility(state.race);
    final needsHighElfCantrip = state.race == 'elf::lineage::high-elf';
    final speciesCantripSpellsAsync =
        needsHighElfCantrip ? ref.watch(classSpellsProvider('wizard')) : null;
    final needsDivineOrder = state.className == 'cleric';
    final clericCantripSpellsAsync =
        needsDivineOrder ? ref.watch(classSpellsProvider('cleric')) : null;
    final needsRangerDruidicWarrior =
        RangerChoiceService.needsDruidicWarriorCantrips(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    );
    final rangerDruidSpellsAsync = needsRangerDruidicWarrior
        ? ref.watch(classSpellsProvider('druid'))
        : null;
    final needsPaladinBlessedWarrior =
        PaladinChoiceService.needsBlessedWarriorCantrips(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    );
    final paladinClericSpellsAsync = needsPaladinBlessedWarrior
        ? ref.watch(classSpellsProvider('cleric'))
        : null;
    final needsDruidMagicianCantrip = DruidChoiceService.needsMagicianCantrip(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    );
    final druidCantripSpellsAsync = needsDruidMagicianCantrip
        ? ref.watch(classSpellsProvider('druid'))
        : null;
    final needsBardLoreMagicalDiscoveries =
        BardChoiceService.needsLoreMagicalDiscoveries(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final bardLoreSpellsAsync =
        needsBardLoreMagicalDiscoveries ? ref.watch(allSpellsProvider) : null;
    final needsBardMoonCantrip = BardChoiceService.isMoon(
      className: state.className,
      subclass: state.subclass,
      level: state.level,
    );
    final bardMoonDruidSpellsAsync =
        needsBardMoonCantrip ? ref.watch(classSpellsProvider('druid')) : null;
    final needsWarlockPactTome = WarlockChoiceService.needsPactTomeChoices(
      className: state.className,
      level: state.level,
      entries: state.levelAdvancements,
    );
    final warlockPactTomeSpellsAsync =
        needsWarlockPactTome ? ref.watch(allSpellsProvider) : null;
    final rogueArcaneTricksterSpellsAsync = needsRogueArcaneTrickster
        ? ref.watch(classSpellsProvider('wizard'))
        : null;
    final fighterEldritchKnightSpellsAsync = needsFighterEldritchKnight
        ? ref.watch(classSpellsProvider('wizard'))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasOriginMagic) ...[
          if (originSpellsAsync == null)
            const SizedBox.shrink()
          else
            originSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 24),
                child: LoadingDragon(label: 'Loading origin feat spells...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load origin feat spells.',
                onRetry: () => ref.invalidate(classSpellsProvider(originList)),
              ),
              data: (spells) =>
                  _buildOriginFeatSpellPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (hasSpeciesOriginMagic) ...[
          if (speciesOriginSpellsAsync == null)
            const SizedBox.shrink()
          else
            speciesOriginSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 24),
                child: LoadingDragon(label: 'Loading human feat spells...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Human Versatile feat spells.',
                onRetry: () =>
                    ref.invalidate(classSpellsProvider(speciesOriginList)),
              ),
              data: (spells) =>
                  _buildSpeciesOriginFeatSpellPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsSpeciesSpellAbility) ...[
          _buildSpeciesSpellAbilityChooser(state),
          const SizedBox(height: 16),
        ],
        if (needsHighElfCantrip) ...[
          if (speciesCantripSpellsAsync == null)
            const SizedBox.shrink()
          else
            speciesCantripSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(label: 'Loading High Elf cantrip...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load High Elf cantrip choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('wizard')),
              ),
              data: (spells) => _buildHighElfCantripPicker(state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsDivineOrder) ...[
          if (clericCantripSpellsAsync == null)
            const SizedBox.shrink()
          else
            clericCantripSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(label: 'Loading Divine Order choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Divine Order choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('cleric')),
              ),
              data: (spells) => _buildDivineOrderChooser(state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsRangerDruidicWarrior) ...[
          if (rangerDruidSpellsAsync == null)
            const SizedBox.shrink()
          else
            rangerDruidSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child:
                    LoadingDragon(label: 'Loading Druidic Warrior choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Druidic Warrior choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('druid')),
              ),
              data: (spells) =>
                  _buildRangerDruidicWarriorPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsPaladinBlessedWarrior) ...[
          if (paladinClericSpellsAsync == null)
            const SizedBox.shrink()
          else
            paladinClericSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child:
                    LoadingDragon(label: 'Loading Blessed Warrior choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Blessed Warrior choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('cleric')),
              ),
              data: (spells) =>
                  _buildPaladinBlessedWarriorPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsDruidMagicianCantrip) ...[
          if (druidCantripSpellsAsync == null)
            const SizedBox.shrink()
          else
            druidCantripSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(label: 'Loading Primal Order choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Primal Order choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('druid')),
              ),
              data: (spells) =>
                  _buildDruidMagicianCantripPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsBardLoreMagicalDiscoveries) ...[
          if (bardLoreSpellsAsync == null)
            const SizedBox.shrink()
          else
            bardLoreSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(
                  label: 'Loading Magical Discoveries choices...',
                ),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Magical Discoveries choices.',
                onRetry: () => ref.invalidate(allSpellsProvider),
              ),
              data: (spells) => _buildBardLoreMagicalDiscoveriesPicker(
                context,
                state,
                spells,
                classRules,
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (needsBardMoonCantrip) ...[
          if (bardMoonDruidSpellsAsync == null)
            const SizedBox.shrink()
          else
            bardMoonDruidSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(label: 'Loading Primal Lore choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Primal Lore choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('druid')),
              ),
              data: (spells) =>
                  _buildBardMoonCantripPicker(context, state, spells),
            ),
          const SizedBox(height: 16),
        ],
        if (needsWarlockPactTome) ...[
          if (warlockPactTomeSpellsAsync == null)
            const SizedBox.shrink()
          else
            warlockPactTomeSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(label: 'Loading Pact Tome choices...'),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Pact Tome choices.',
                onRetry: () => ref.invalidate(allSpellsProvider),
              ),
              data: (spells) => WarlockPactTomePicker(
                state: state,
                spells: spells,
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (needsRogueArcaneTrickster) ...[
          if (rogueArcaneTricksterSpellsAsync == null)
            const SizedBox.shrink()
          else
            rogueArcaneTricksterSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(
                  label: 'Loading Arcane Trickster choices...',
                ),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Arcane Trickster choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('wizard')),
              ),
              data: (spells) => RogueArcaneTricksterSpellPicker(
                state: state,
                spells: spells,
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (needsFighterEldritchKnight) ...[
          if (fighterEldritchKnightSpellsAsync == null)
            const SizedBox.shrink()
          else
            fighterEldritchKnightSpellsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LoadingDragon(
                  label: 'Loading Eldritch Knight choices...',
                ),
              ),
              error: (_, __) => _ErrorBlock(
                message: 'Failed to load Eldritch Knight choices.',
                onRetry: () => ref.invalidate(classSpellsProvider('wizard')),
              ),
              data: (spells) => FighterEldritchKnightSpellPicker(
                state: state,
                spells: spells,
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (isNonCaster) ...[
          _InfoMessage(
            emoji: hasOriginMagic || hasSpeciesOriginMagic ? '✨' : '⚔️',
            title: hasOriginMagic || hasSpeciesOriginMagic
                ? 'Origin feat spell selection'
                : '${state.classDisplayName} is not a spellcaster',
            subtitle: hasOriginMagic || hasSpeciesOriginMagic
                ? 'Your class has no normal spell list, but your origin feat choices still grant spell choices below.'
                : 'You can skip this step.',
          ),
          Builder(builder: (context) {
            final subclassGranted = kSubclassGrantedSpells2024[state.subclass];
            final speciesGranted = kSpeciesGrantedSpells2024[state.race];
            if (subclassGranted == null && speciesGranted == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _GrantedSpellsPreview(
                title: 'Granted Spells — Added Automatically',
                subclassName: state.subclassName,
                subclassMap: subclassGranted,
                speciesName: state.raceName,
                speciesMap: speciesGranted,
              ),
            );
          }),
        ] else if (classSpellsAsync != null)
          classSpellsAsync.when(
            loading: () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const LoadingDragon(label: 'Loading class spells...'),
                const SizedBox(height: 16),
                Text(
                  'Loading ${state.classDisplayName} spells...',
                  style: AppTextStyles.lato(color: Colors.white54),
                ),
              ],
            ),
            error: (_, __) => _ErrorBlock(
              message: 'Failed to load spells',
              onRetry: () {
                if (needsBardMagicalSecrets) {
                  ref.invalidate(allSpellsProvider);
                } else {
                  ref.invalidate(classSpellsProvider(state.className));
                }
              },
            ),
            data: (allSpells) {
              final spellOptions = needsBardMagicalSecrets
                  ? BardChoiceService.filterMagicalSecretsSpellOptions(
                      spells: allSpells,
                    )
                  : allSpells;
              return _buildClassSpellPicker(
                context,
                state,
                spellOptions,
                classRules,
              );
            },
          ),
      ],
    );
  }

  void _updateUi(VoidCallback update) => setState(update);
}
