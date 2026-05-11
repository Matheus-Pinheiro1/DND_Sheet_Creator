part of '../step_class.dart';

class _BarbarianCombatChoices extends ConsumerWidget {
  const _BarbarianCombatChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedWeapons = BarbarianChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
      characterLevel: state.level,
    );
    final requiredWeapons =
        BarbarianChoiceService.weaponMasterySelectionCountForLevel(
      state.level,
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
            'Barbarian Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose $requiredWeapons Simple or Martial Melee weapons for Weapon Mastery.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Weapon Mastery - ${selectedWeapons.length} / $requiredWeapons',
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
            children: BarbarianChoiceService.weaponMasteryOptions.map((weapon) {
              final selected = selectedWeapons.contains(weapon.name);
              final disabled =
                  !selected && selectedWeapons.length >= requiredWeapons;

              return FilterChip(
                label: Text(weapon.name),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedWeapons);
                        if (value) {
                          next.add(weapon.name);
                        } else {
                          next.remove(weapon.name);
                        }
                        notifier.setBarbarianWeaponMasteries(next);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FighterCombatChoices extends ConsumerWidget {
  const _FighterCombatChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedWeapons = FighterChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
      characterLevel: state.level,
    );
    final requiredWeapons =
        FighterChoiceService.weaponMasterySelectionCountForLevel(
      state.level,
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
            'Fighter Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose $requiredWeapons Simple or Martial weapons for Weapon Mastery.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Weapon Mastery - ${selectedWeapons.length} / $requiredWeapons',
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
            children: FighterChoiceService.weaponMasteryOptions.map((weapon) {
              final selected = selectedWeapons.contains(weapon.name);
              final disabled =
                  !selected && selectedWeapons.length >= requiredWeapons;

              return FilterChip(
                label: Text(weapon.name),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedWeapons);
                        if (value) {
                          next.add(weapon.name);
                        } else {
                          next.remove(weapon.name);
                        }
                        notifier.setFighterWeaponMasteries(next);
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ArtificerBaseChoices extends ConsumerWidget {
  const _ArtificerBaseChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedSkills = ArtificerChoiceService.selectedSkillProficiencies(
      state.levelAdvancements,
    );
    final selectedTool =
        ArtificerChoiceService.selectedArtisanTool(state.levelAdvancements);
    const requiredSkills = ArtificerChoiceService.skillSelectionCount;

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
            'Artificer Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Choose two Artificer skills and one Artisan's Tool. Mending is added automatically by Tinker's Magic.",
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Skills - ${selectedSkills.length} / $requiredSkills',
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
            children: ArtificerChoiceService.skillOptions.map((skill) {
              final selected = selectedSkills.contains(skill);
              final disabled =
                  !selected && selectedSkills.length >= requiredSkills;

              return FilterChip(
                label: Text(ArtificerChoiceService.skillLabel(skill)),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedSkills);
                        if (value) {
                          next.add(skill);
                        } else {
                          next.remove(skill);
                        }
                        notifier.setArtificerSkillChoices(next);
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            selectedTool == null
                ? "Artisan's Tool - 0 / 1"
                : "Artisan's Tool - 1 / 1",
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
                ArtificerChoiceService.selectableArtisanToolOptions.map((tool) {
              return ChoiceChip(
                label: Text(tool),
                selected: selectedTool == tool,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => notifier.setArtificerArtisanTool(tool),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PaladinCombatChoices extends ConsumerWidget {
  const _PaladinCombatChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedWeapons = PaladinChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
    );
    final selectedStyle = PaladinChoiceService.selectedFightingStyle(
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
            'Paladin Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose two Simple or Martial weapons for Weapon Mastery. At Paladin level 2, choose one Fighting Style.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Weapon Mastery - ${selectedWeapons.length} / ${PaladinChoiceService.weaponMasterySelectionCount}',
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
            children: kDndWeapons.map((weapon) {
              final selected = selectedWeapons.contains(weapon.name);
              final disabled = !selected &&
                  selectedWeapons.length >=
                      PaladinChoiceService.weaponMasterySelectionCount;

              return FilterChip(
                label: Text(weapon.name),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedWeapons);
                        if (value) {
                          next.add(weapon.name);
                        } else {
                          next.remove(weapon.name);
                        }
                        notifier.setPaladinWeaponMasteries(next);
                      },
              );
            }).toList(),
          ),
          if (state.level >= 2) ...[
            const SizedBox(height: 16),
            Text(
              'Fighting Style',
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
              children: PaladinChoiceService.fightingStyleOptions.map((style) {
                return ChoiceChip(
                  label: Text(style),
                  selected: selectedStyle == style,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => notifier.setPaladinFightingStyle(style),
                );
              }).toList(),
            ),
            if (selectedStyle == 'Blessed Warrior') ...[
              const SizedBox(height: 8),
              Text(
                'Choose the two Cleric cantrips in the Spells step.',
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

class _BattleMasterSubclassChoices extends ConsumerWidget {
  const _BattleMasterSubclassChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selected = FighterChoiceService.selectedBattleMasterManeuvers(
      state.levelAdvancements,
      characterLevel: state.level,
    );
    final required =
        FighterChoiceService.battleMasterManeuverCountForLevel(state.level);

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
            'Battle Master Maneuvers',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose maneuvers fueled by your Superiority Dice. Student of War skill and tool choices are handled in the Skills step.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selected.length} / $required maneuvers selected',
            style: AppTextStyles.lato(
              color: selected.length == required
                  ? Colors.greenAccent
                  : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: FighterChoiceService.maneuverOptions.map((maneuver) {
              final isSelected = selected.contains(maneuver.id);
              final disabled = !isSelected && selected.length >= required;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BattleMasterManeuverTile(
                  maneuver: maneuver,
                  isSelected: isSelected,
                  isDisabled: disabled,
                  onTap: () {
                    final next = List<String>.from(selected);
                    if (isSelected) {
                      next.remove(maneuver.id);
                    } else {
                      next.add(maneuver.id);
                    }
                    notifier.setFighterBattleMasterManeuvers(next);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BattleMasterManeuverTile extends StatelessWidget {
  final BattleMasterManeuverOption maneuver;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _BattleMasterManeuverTile({
    required this.maneuver,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppTheme.gold
        : isDisabled
            ? Colors.white10
            : Colors.white24;
    final backgroundColor = isSelected
        ? AppTheme.crimson.withValues(alpha: 0.28)
        : AppTheme.charcoal.withValues(alpha: 0.58);

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppTheme.gold : Colors.white38,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maneuver.label,
                        style: AppTextStyles.cinzel(
                          color: isSelected ? AppTheme.gold : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maneuver.summary,
                        style: AppTextStyles.lato(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RangerCombatChoices extends ConsumerWidget {
  const _RangerCombatChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selectedWeapons = RangerChoiceService.selectedWeaponMasteries(
      state.levelAdvancements,
    );
    final selectedStyle = RangerChoiceService.selectedFightingStyle(
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
            'Ranger Base Choices',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose two Simple or Martial weapons for Weapon Mastery. At Ranger level 2, choose one Fighting Style.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Weapon Mastery — ${selectedWeapons.length} / ${RangerChoiceService.weaponMasterySelectionCount}',
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
            children: RangerChoiceService.weaponMasteryOptions.map((weapon) {
              final selected = selectedWeapons.contains(weapon.name);
              final disabled = !selected &&
                  selectedWeapons.length >=
                      RangerChoiceService.weaponMasterySelectionCount;

              return FilterChip(
                label: Text(weapon.name),
                selected: selected,
                selectedColor: AppTheme.crimson,
                onSelected: disabled
                    ? null
                    : (value) {
                        final next = List<String>.from(selectedWeapons);
                        if (value) {
                          next.add(weapon.name);
                        } else {
                          next.remove(weapon.name);
                        }
                        notifier.setRangerWeaponMasteries(next);
                      },
              );
            }).toList(),
          ),
          if (state.level >= 2) ...[
            const SizedBox(height: 16),
            Text(
              'Fighting Style',
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
              children: RangerChoiceService.fightingStyleOptions.map((style) {
                return ChoiceChip(
                  label: Text(style),
                  selected: selectedStyle == style,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) => notifier.setRangerFightingStyle(style),
                );
              }).toList(),
            ),
            if (selectedStyle == 'Druidic Warrior') ...[
              const SizedBox(height: 8),
              Text(
                'Choose the two Druid cantrips in the Spells step.',
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

class _RogueScionSubclassChoices extends ConsumerWidget {
  const _RogueScionSubclassChoices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(creationProvider);
    final notifier = ref.read(creationProvider.notifier);
    final selected = RogueChoiceService.selectedScionDreadAllegiance(
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
            'Scion of the Three',
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your Dread Allegiance. It grants one resistance and one Intelligence-based cantrip.',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RogueChoiceService.scionAllegianceIds.map((id) {
              return ChoiceChip(
                label: Text(RogueChoiceService.scionDreadAllegianceLabel(id)),
                selected: selected == id,
                selectedColor: AppTheme.crimson,
                onSelected: (_) => notifier.setRogueScionDreadAllegiance(id),
              );
            }).toList(),
          ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            Text(
              RogueChoiceService.scionDreadAllegianceSummary(selected),
              style: AppTextStyles.lato(
                color: Colors.white54,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
