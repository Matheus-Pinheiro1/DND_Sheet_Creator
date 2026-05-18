import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dice_calculator.dart';
import '../../../../data/local/granted_spells_2024.dart';
import '../../../../data/models/character_model.dart';
import '../../../../data/remote/spell_dto.dart';
import '../../../../providers/character_providers.dart';
import '../../../../providers/dnd_api_providers.dart';
import '../../../../data/services/barbarian_choice_service.dart';
import '../../../../data/services/fighter_choice_service.dart';
import '../../../../data/services/progression_service.dart';
import '../../../../data/services/rogue_choice_service.dart';
import '../../../../data/services/bard_choice_service.dart';
import '../../../../data/services/druid_choice_service.dart';
import '../../../../data/services/wizard_choice_service.dart';
import '../../../../core/utils/character_helpers.dart';
import '../../shared/dialogs/spell_detail_dialog.dart';
import '../../shared/widgets/loading_dragon.dart';
import '../../shared/widgets/spell_card.dart';
import '../../shared/widgets/stat_box.dart';

part 'tab_spells_helpers.dart';
part 'tab_spells_widgets.dart';

class TabSpells extends ConsumerWidget {
  final CharacterModel character;
  const TabSpells({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displaySpellIndices = _displaySpellIndices();
    if (character.spellcastingAbility.isEmpty && displaySpellIndices.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, size: 56, color: Colors.white38),
          const SizedBox(height: 16),
          Text('Not a spellcaster',
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
              )),
        ],
      ));
    }

    if (character.className.startsWith('custom_class_') &&
        displaySpellIndices.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 56, color: Colors.white38),
          const SizedBox(height: 16),
          Text('Homebrew class spells are manual for now',
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
              )),
          const SizedBox(height: 8),
          Text(
              'Official API spell lists are not available for local homebrew classes.',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
              ),
              textAlign: TextAlign.center),
        ],
      ));
    }

    if (displaySpellIndices.isEmpty) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 56, color: Colors.white38),
          const SizedBox(height: 16),
          Text('No spells selected',
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
              )),
          const SizedBox(height: 8),
          Text('Edit character to add spells.',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
              )),
        ],
      ));
    }

    final spellsAsync = ref.watch(allSpellsProvider);

    return spellsAsync.when(
      loading: () => const LoadingDragon(label: 'Preparing spellbook...'),
      error: (_, __) => Center(
          child: Column(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 8),
        const Text('Failed to load spell data.'),
        ElevatedButton(
          onPressed: () => ref.invalidate(allSpellsProvider),
          child: const Text('Refresh'),
        ),
      ])),
      data: (allSpells) {
        final grantedSpellMap = _grantedSpellMap(allSpells);
        final originSpellIds = _originSpellIds();
        final featGrantedSpellMap = _featGrantedSpellMap(allSpells);
        final specialChoiceSpellMap = _specialChoiceSpellMap();
        final mySpells = allSpells
            .where((s) => displaySpellIndices.contains(s.index))
            .toList()
          ..sort((a, b) => a.level == b.level
              ? a.name.compareTo(b.name)
              : a.level.compareTo(b.level));

        final grouped = <int, List<SpellDto>>{};
        for (final spell in mySpells) {
          grouped.putIfAbsent(spell.level, () => []).add(spell);
        }

        final effectiveAbility = _getEffectiveSpellAbility();
        final profBonus = DiceCalculator.getProficiencyBonus(character.level);
        final abilityScore = _getAbilityScore(effectiveAbility);
        final abilityMod = DiceCalculator.getModifier(abilityScore);
        final spellAttack = abilityMod + profBonus;
        final saveDC = 8 + abilityMod + profBonus;
        final isArcaneTrickster = RogueChoiceService.isArcaneTrickster(
          className: character.className,
          subclass: character.subclass,
          level: character.level,
        );
        final isEldritchKnight = FighterChoiceService.isEldritchKnight(
          className: character.className,
          subclass: character.subclass,
          level: character.level,
        );
        final limits = isArcaneTrickster
            ? SpellSelectionLimits(
                maxCantrips: RogueChoiceService.arcaneTricksterCantripCount(
                      character.level,
                    ) +
                    1,
                maxLeveledSpells:
                    RogueChoiceService.arcaneTricksterPreparedSpellCount(
                  character.level,
                ),
                maxSpellLevel: RogueChoiceService.arcaneTricksterMaxSpellLevel(
                  character.level,
                ),
                spellSlots: RogueChoiceService.arcaneTricksterSpellSlots(
                  character.level,
                ),
                helperText:
                    'Arcane Trickster spells use Intelligence. Mage Hand is included automatically.',
              )
            : isEldritchKnight
                ? SpellSelectionLimits(
                    maxCantrips:
                        FighterChoiceService.eldritchKnightCantripCount(
                      character.level,
                    ),
                    maxLeveledSpells:
                        FighterChoiceService.eldritchKnightPreparedSpellCount(
                      character.level,
                    ),
                    maxSpellLevel:
                        FighterChoiceService.eldritchKnightMaxSpellLevel(
                      character.level,
                    ),
                    spellSlots: FighterChoiceService.eldritchKnightSpellSlots(
                      character.level,
                    ),
                    helperText:
                        'Eldritch Knight spells use Intelligence and the Wizard spell list.',
                  )
                : ProgressionService.getSpellLimits(
                    CharacterSpellProxy(character),
                  );
        final rawEffectiveSpellSlotsMax = isArcaneTrickster
            ? character.spellSlotsMax.any((slot) => slot > 0)
                ? character.spellSlotsMax
                : RogueChoiceService.arcaneTricksterSpellSlotsListFor(
                    character.level,
                  )
            : isEldritchKnight
                ? character.spellSlotsMax.any((slot) => slot > 0)
                    ? character.spellSlotsMax
                    : FighterChoiceService.eldritchKnightSpellSlotsListFor(
                        character.level,
                      )
                : character.spellcastingAbility.isNotEmpty
                    ? ProgressionService.getSpellSlotsListFor(
                        className: character.className,
                        level: character.level,
                      )
                    : character.spellSlotsMax;
        final effectiveSpellSlotsMax =
            _normalizeSpellSlots(rawEffectiveSpellSlotsMax);
        final spellSlotsUsed = _normalizeSpellSlots(
          character.spellSlotsUsed,
        );
        final manualSpells = mySpells
            .where((spell) =>
                !grantedSpellMap.containsKey(spell.index) &&
                !originSpellIds.contains(spell.index) &&
                !featGrantedSpellMap.containsKey(spell.index) &&
                !specialChoiceSpellMap.containsKey(spell.index))
            .toList();
        final selectedCantrips = isArcaneTrickster
            ? RogueChoiceService.selectedArcaneTricksterCantrips(
                  character.levelAdvancements,
                ).length +
                1
            : isEldritchKnight
                ? FighterChoiceService.selectedEldritchKnightCantrips(
                    character.levelAdvancements,
                  ).length
                : manualSpells.where((s) => s.level == 0).length;
        final selectedLeveled = isArcaneTrickster
            ? RogueChoiceService.selectedArcaneTricksterSpells(
                character.levelAdvancements,
              ).length
            : isEldritchKnight
                ? FighterChoiceService.selectedEldritchKnightSpells(
                    character.levelAdvancements,
                  ).length
                : manualSpells.where((s) => s.level > 0).length;

        return Column(
          children: [
            if (character.concentrationSpell.isNotEmpty)
              _ConcentrationBanner(
                spellName: character.concentrationSpell,
                onEnd: () =>
                    ref.read(charactersProvider.notifier).updateCharacter(
                          character.copyWith(concentrationSpell: ''),
                        ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: StatBox(
                              label: 'Spell Attack',
                              value: '+$spellAttack',
                              icon: Icons.gps_fixed)),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                      Expanded(
                          child: StatBox(
                              label: 'Save DC',
                              value: '$saveDC',
                              icon: Icons.shield_outlined)),
                      const SizedBox(width: 8),
                      const SizedBox(width: 8),
                      Expanded(
                          child: StatBox(
                              label: 'Ability',
                              value: effectiveAbility.isEmpty
                                  ? '-'
                                  : effectiveAbility.toUpperCase(),
                              icon: Icons.psychology_outlined)),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spell Limits',
                            style: AppTextStyles.cinzel(
                              color: AppTheme.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cantrips: $selectedCantrips/${limits.maxCantrips} - Leveled: $selectedLeveled/${limits.maxLeveledSpells}',
                            style: AppTextStyles.lato(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            limits.helperText,
                            style: AppTextStyles.lato(
                              color: Colors.white60,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (effectiveSpellSlotsMax.any((s) => s > 0)) ...[
                      Text('Spell Slots',
                          style: AppTextStyles.cinzel(
                            color: AppTheme.gold,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 8),
                      ...List.generate(9, (i) {
                        final max = effectiveSpellSlotsMax[i];
                        final used = spellSlotsUsed[i].clamp(0, max).toInt();
                        if (max == 0) return const SizedBox.shrink();
                        return _SpellSlotRow(
                          level: i + 1,
                          max: max,
                          used: used,
                          onToggle: (newUsed) async {
                            final u = _normalizeSpellSlots(
                              character.spellSlotsUsed,
                            );
                            u[i] = newUsed;
                            await ref
                                .read(charactersProvider.notifier)
                                .updateCharacter(
                                  character.copyWith(spellSlotsUsed: u),
                                );
                          },
                        );
                      }),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(charactersProvider.notifier).updateCharacter(
                                character.copyWith(
                                  spellSlotsUsed: List.filled(9, 0),
                                ),
                              );
                        },
                        icon: const Icon(Icons.bedtime_outlined,
                            size: 14, color: Colors.blueAccent),
                        label: Text('Long Rest - Reset all slots',
                            style: AppTextStyles.lato(
                              color: Colors.blueAccent,
                              fontSize: 13,
                            )),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ...grouped.entries.map((entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                entry.key == 0
                                    ? 'Cantrips'
                                    : 'Spells - Level ${entry.key}',
                                style: AppTextStyles.cinzel(
                                  color: AppTheme.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...entry.value.map((s) {
                              final granted = grantedSpellMap[s.index];
                              final featGranted = featGrantedSpellMap[s.index];
                              final sourceText = granted != null
                                  ? character.className == 'monk'
                                      ? 'Granted by ${granted.sourceLabel} - Unlocked at level ${granted.unlockLevel}'
                                      : 'Always Prepared - ${granted.sourceLabel} - Unlocked at level ${granted.unlockLevel}'
                                  : originSpellIds.contains(s.index)
                                      ? 'Granted by Origin Feat'
                                      : featGranted ??
                                          specialChoiceSpellMap[s.index];
                              return SpellCard(
                                spell: s,
                                isConcentrating:
                                    character.concentrationSpell == s.name,
                                sourceText: sourceText,
                                onTap: () => showSpellDetailDialog(context, s),
                                onConcentrate: s.concentration
                                    ? () {
                                        final isCurrentlyThis =
                                            character.concentrationSpell ==
                                                s.name;
                                        ref
                                            .read(charactersProvider.notifier)
                                            .updateCharacter(
                                              character.copyWith(
                                                concentrationSpell:
                                                    isCurrentlyThis
                                                        ? ''
                                                        : s.name,
                                              ),
                                            );
                                      }
                                    : null,
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Set<String> _displaySpellIndices() {
    final indices = <String>{...character.selectedSpells};
    indices.addAll(_specialChoiceSpellMap().keys);
    indices.addAll(
      RogueChoiceService.arcaneTricksterSpellIds(
        className: character.className,
        subclass: character.subclass,
        level: character.level,
        entries: character.levelAdvancements,
      ),
    );
    indices.addAll(
      FighterChoiceService.eldritchKnightSpellIds(
        className: character.className,
        subclass: character.subclass,
        level: character.level,
        entries: character.levelAdvancements,
      ),
    );
    indices.addAll(
      FighterChoiceService.psiWarriorGrantedSpellIds(
        className: character.className,
        subclass: character.subclass,
        level: character.level,
      ),
    );
    indices.addAll(
      DruidChoiceService.landSpellIds(
        className: character.className,
        subclass: character.subclass,
        level: character.level,
        entries: character.levelAdvancements,
      ),
    );
    final scionCantrip = RogueChoiceService.scionDreadAllegianceCantrip(
      character.levelAdvancements,
    );
    if (scionCantrip != null) {
      indices.add(scionCantrip);
    }
    indices.addAll(_originSpellIds());
    indices.addAll(
      buildGrantedSpellEntries(
        className: character.className,
        subclass: character.subclass,
        raceValue: character.race,
        level: character.level,
      ).map((entry) => entry.spellIndex),
    );
    for (final entry in character.levelAdvancements) {
      if (entry.startsWith('feat:magic-initiate-')) {
        final parts = entry.split(':');
        if (parts.length > 3) {
          indices.addAll(
            parts[3]
                .split(',')
                .map((spell) => spell.trim())
                .where((spell) => spell.isNotEmpty),
          );
        }
        if (parts.length > 4 && parts[4].trim().isNotEmpty) {
          indices.add(parts[4].trim());
        }
      }
    }
    return indices;
  }

  Set<String> _originSpellIds() {
    return character.levelAdvancements
        .where((entry) =>
            entry.startsWith('origin_cantrip:') ||
            entry.startsWith('origin_spell:') ||
            entry.startsWith('species_choice:versatile_cantrip:') ||
            entry.startsWith('species_choice:versatile_spell:'))
        .map((entry) => entry.split(':').last)
        .where((value) => value.trim().isNotEmpty)
        .toSet();
  }

  Map<String, String> _featGrantedSpellMap(List<SpellDto> allSpells) {
    final byIndex = {for (final spell in allSpells) spell.index: spell.name};
    final result = <String, String>{};

    void add(String spellIndex, String label) {
      if (spellIndex.trim().isEmpty || !byIndex.containsKey(spellIndex)) return;
      result[spellIndex] = label;
    }

    for (final entry in character.levelAdvancements) {
      if (entry.startsWith('feat:magic-initiate-')) {
        final parts = entry.split(':');
        if (parts.length > 3) {
          for (final cantrip in parts[3].split(',')) {
            if (cantrip.trim().isNotEmpty) {
              add(cantrip.trim(), 'Granted by ${parts[1]}');
            }
          }
        }
        if (parts.length > 4 && parts[4].trim().isNotEmpty) {
          add(parts[4].trim(), 'Granted by ${parts[1]}');
        }
      } else if (entry.startsWith('feat:fey-touched:')) {
        final parts = entry.split(':');
        add('misty-step', 'Granted by Fey Touched');
        if (parts.length > 3 && parts[3].trim().isNotEmpty) {
          add(parts[3].trim(), 'Granted by Fey Touched');
        }
      } else if (entry.startsWith('feat:shadow-touched:')) {
        final parts = entry.split(':');
        add('invisibility', 'Granted by Shadow Touched');
        if (parts.length > 3 && parts[3].trim().isNotEmpty) {
          add(parts[3].trim(), 'Granted by Shadow Touched');
        }
      } else if (entry.startsWith('feat:telepathic:')) {
        add('detect-thoughts', 'Granted by Telepathic');
      } else if (entry.startsWith('feat:telekinetic:')) {
        add('mage-hand', 'Granted by Telekinetic');
      } else if (entry.startsWith('feat:ritualist:')) {
        final parts = entry.split(':');
        if (parts.length > 3) {
          for (final spell in parts[3].split(',')) {
            if (spell.trim().isNotEmpty) {
              add(spell.trim(), 'Granted by Ritualist');
            }
          }
        }
      }
    }

    return result;
  }

  Map<String, String> _specialChoiceSpellMap() {
    final result = <String, String>{};
    final isHumanSpecies = _selectedBaseRaceId(character.race) == 'human';
    for (final entry in character.levelAdvancements) {
      if (entry.startsWith('species_choice:granted_cantrip:')) {
        final spell = entry.replaceFirst('species_choice:granted_cantrip:', '');
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Species Choice';
        }
      } else if (isHumanSpecies &&
          entry.startsWith('species_choice:versatile_cantrip:')) {
        final spell =
            entry.replaceFirst('species_choice:versatile_cantrip:', '');
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Human Versatile';
        }
      } else if (isHumanSpecies &&
          entry.startsWith('species_choice:versatile_spell:')) {
        final spell = entry.replaceFirst('species_choice:versatile_spell:', '');
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Human Versatile';
        }
      } else if (entry.startsWith('class_choice:divine_order_cantrip:')) {
        final spell = entry.replaceFirst(
          'class_choice:divine_order_cantrip:',
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Divine Order';
        }
      } else if (entry.startsWith(WizardChoiceService.savantEntryPrefix)) {
        final parts = entry.split(':');
        if (parts.length > 3 && parts[3].trim().isNotEmpty) {
          result[parts[3].trim()] =
              'Added by ${WizardChoiceService.savantFeatureNameForSubclass(character.subclass)}';
        }
      } else if (entry
          .startsWith(WizardChoiceService.illusionistCantripPrefix)) {
        final spell = entry.replaceFirst(
          WizardChoiceService.illusionistCantripPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Improved Illusions';
        }
      } else if (entry.startsWith(
        RogueChoiceService.arcaneTricksterCantripEntryPrefix,
      )) {
        final spell = entry.replaceFirst(
          RogueChoiceService.arcaneTricksterCantripEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Chosen by Arcane Trickster';
        }
      } else if (entry.startsWith(
        RogueChoiceService.arcaneTricksterSpellEntryPrefix,
      )) {
        final spell = entry.replaceFirst(
          RogueChoiceService.arcaneTricksterSpellEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Prepared by Arcane Trickster';
        }
      } else if (entry.startsWith(
        RogueChoiceService.scionDreadAllegianceEntryPrefix,
      )) {
        final spell = RogueChoiceService.scionDreadAllegianceCantrip(
          character.levelAdvancements,
        );
        if (spell != null && spell.isNotEmpty) {
          result[spell] = 'Granted by Dread Allegiance';
        }
      } else if (entry.startsWith(
        FighterChoiceService.eldritchKnightCantripEntryPrefix,
      )) {
        final spell = entry.replaceFirst(
          FighterChoiceService.eldritchKnightCantripEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Chosen by Eldritch Knight';
        }
      } else if (entry.startsWith(
        FighterChoiceService.eldritchKnightSpellEntryPrefix,
      )) {
        final spell = entry.replaceFirst(
          FighterChoiceService.eldritchKnightSpellEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Prepared by Eldritch Knight';
        }
      } else if (entry.startsWith(
        BardChoiceService.loreDiscoverySpellEntryPrefix,
      )) {
        final spell = entry.replaceFirst(
          BardChoiceService.loreDiscoverySpellEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Discovered by College of Lore';
        }
      } else if (entry.startsWith(BardChoiceService.moonCantripEntryPrefix)) {
        final spell = entry.replaceFirst(
          BardChoiceService.moonCantripEntryPrefix,
          '',
        );
        if (spell.isNotEmpty) {
          result[spell] = 'Granted by Primal Lore';
        }
      }
    }
    final druidLandType = DruidChoiceService.selectedLandType(
      character.levelAdvancements,
    );
    if (druidLandType != null) {
      for (final spell in DruidChoiceService.landSpellIds(
        className: character.className,
        subclass: character.subclass,
        level: character.level,
        entries: character.levelAdvancements,
      )) {
        result[spell] =
            'Circle of the Land (${DruidChoiceService.landTypeLabel(druidLandType)})';
      }
    }
    if (FighterChoiceService.isPsiWarrior(
          className: character.className,
          subclass: character.subclass,
          level: character.level,
        ) &&
        character.level >= 18) {
      result['telekinesis'] = 'Granted by Telekinetic Master';
    }
    if (RogueChoiceService.isArcaneTrickster(
      className: character.className,
      subclass: character.subclass,
      level: character.level,
    )) {
      result[RogueChoiceService.mageHandSpellId] =
          'Granted by Arcane Trickster';
    }
    if (character.className == 'wizard' &&
        character.subclass == 'wizard-illusionist' &&
        character.level >= 3 &&
        !result.containsKey('minor-illusion') &&
        WizardChoiceService.selectedIllusionistBonusCantrip(
              character.levelAdvancements,
            ) ==
            null) {
      result['minor-illusion'] = 'Granted by Improved Illusions';
    }
    return result;
  }

  Map<String, GrantedSpellEntry> _grantedSpellMap(List<SpellDto> allSpells) {
    final byName = buildSpellNameIndexMap(allSpells);
    final entries = buildGrantedSpellEntries(
      className: character.className,
      subclass: character.subclass,
      raceValue: character.race,
      level: character.level,
      spellNameToIndex: byName,
    );
    return {for (final entry in entries) entry.spellIndex: entry};
  }
}
