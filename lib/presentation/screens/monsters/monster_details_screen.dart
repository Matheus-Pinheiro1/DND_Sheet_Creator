// lib/presentation/screens/monsters/monster_details_screen.dart

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/utils/monster_combat_helpers.dart';
import 'package:dnd_character_sheet/data/models/encounter_participant.dart';
import 'package:dnd_character_sheet/data/remote/monster_dto.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/providers/encounter_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/widgets/loading_dragon.dart';
import '../shared/widgets/stat_box.dart';

class MonsterDetailScreen extends ConsumerWidget {
  final String monsterIndex;
  const MonsterDetailScreen({super.key, required this.monsterIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monsterAsync = ref.watch(monsterDetailProvider(monsterIndex));
    final encounter = ref.watch(encounterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monster Details'),
        actions: [
          monsterAsync.whenOrNull(
                data: (monster) {
                  final countInEncounter = encounter.participants
                      .where((p) => p.monsterIndex == monsterIndex)
                      .length;
                  return TextButton.icon(
                    onPressed: () => _addToEncounter(ref, monster),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      countInEncounter > 0
                          ? 'Add again (#${countInEncounter + 1})'
                          : 'Add to Encounter',
                      style: AppTextStyles.lato(
                          color: AppTheme.gold, fontSize: 13),
                    ),
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: monsterAsync.when(
        loading: () => const LoadingDragon(label: 'Reading monster sheet...'),
        error: (error, _) => Center(
          child: Text('Failed to load monster: $error',
              style: AppTextStyles.lato()),
        ),
        data: (monster) => _MonsterDetailBody(monster: monster),
      ),
    );
  }

  void _addToEncounter(
    WidgetRef ref,
    MonsterDetailDto monster,
  ) {
    final legendaryActionsCount = MonsterCombatHelpers.legendaryActionsMax(
      monster.legendaryActions,
    );
    final legendaryResistancesCount =
        MonsterCombatHelpers.legendaryResistancesMax(
      monster.specialAbilities,
    );

    final participant = EncounterParticipant.fromMonster(
      monsterIndex: monster.index,
      name: monster.name,
      type: monster.type,
      crLabel: monster.challengeRatingLabel,
      hp: monster.hitPoints,
      ac: monster.armorClass,
      legendaryActionsCount: legendaryActionsCount,
      legendaryResistancesCount: legendaryResistancesCount,
    );

    ref.read(encounterProvider.notifier).addParticipant(participant);
  }
}

class _MonsterDetailBody extends StatelessWidget {
  final MonsterDetailDto monster;
  const _MonsterDetailBody({required this.monster});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monster.name,
              style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${monster.size} ${monster.type} • ${monster.alignment}',
              style: AppTextStyles.lato(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                  width: 80,
                  child: StatBox(label: 'AC', value: '${monster.armorClass}')),
              SizedBox(
                  width: 80,
                  child: StatBox(label: 'HP', value: '${monster.hitPoints}')),
              SizedBox(
                  width: 80,
                  child: StatBox(
                      label: 'CR', value: monster.challengeRatingLabel)),
              SizedBox(
                  width: 100,
                  child: StatBox(label: 'XP', value: '${monster.xp ?? 0}')),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Core Stats',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniStat('STR', monster.strength),
                _MiniStat('DEX', monster.dexterity),
                _MiniStat('CON', monster.constitution),
                _MiniStat('INT', monster.intelligence),
                _MiniStat('WIS', monster.wisdom),
                _MiniStat('CHA', monster.charisma),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Saving Throws',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA']
                  .map((ability) => _SavingThrowStat(
                        label: ability,
                        value: monster.savingThrowFor(ability),
                        proficient:
                            monster.savingThrowBonuses.containsKey(ability),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
              title: 'Vital Stats',
              child: Text('Hit Dice: ${monster.hitDice}')),
          const SizedBox(height: 12),
          _SectionCard(title: 'Speed', child: Text(_formatMap(monster.speed))),
          if (monster.senses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
                title: 'Senses', child: Text(_formatMap(monster.senses))),
          ],
          if (monster.languages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
                title: 'Languages', child: Text(monster.languages.join(', '))),
          ],
          if (monster.proficiencies.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
                title: 'Proficiencies',
                child: Text(monster.proficiencies.join(' • '))),
          ],
          if (monster.damageResistances.isNotEmpty ||
              monster.damageImmunities.isNotEmpty ||
              monster.conditionImmunities.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Defenses',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (monster.damageResistances.isNotEmpty)
                    Text(
                        'Resistances: ${monster.damageResistances.join(', ')}'),
                  if (monster.damageImmunities.isNotEmpty)
                    Text('Immunities: ${monster.damageImmunities.join(', ')}'),
                  if (monster.conditionImmunities.isNotEmpty)
                    Text(
                        'Condition Immunities: ${monster.conditionImmunities.join(', ')}'),
                ],
              ),
            ),
          ],
          ..._sectionsFromEntries(
              'Special Abilities', monster.specialAbilities),
          ..._sectionsFromEntries('Actions', monster.actions),
          ..._sectionsFromEntries('Bonus Actions', monster.bonusActions),
          ..._sectionsFromEntries('Reactions', monster.reactions),
          ..._sectionsFromEntries(
              'Legendary Actions', monster.legendaryActions),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _sectionsFromEntries(
      String title, List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      _SectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((entry) {
            final name = (entry['name'] ?? '').toString();
            final desc = (entry['desc'] ?? '').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: AppTextStyles.lato(
                          color: Colors.white70, fontSize: 13, height: 1.45)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  String _formatMap(Map<String, dynamic> values) {
    return values.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DefaultTextStyle(
            style: AppTextStyles.lato(
                color: Colors.white70, fontSize: 13, height: 1.45),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int score;
  const _MiniStat(this.label, this.score);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Column(
        children: [
          Text('$score',
              style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SavingThrowStat extends StatelessWidget {
  final String label;
  final int value;
  final bool proficient;

  const _SavingThrowStat({
    required this.label,
    required this.value,
    required this.proficient,
  });

  @override
  Widget build(BuildContext context) {
    final signed = value >= 0 ? '+$value' : '$value';

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: proficient
            ? AppTheme.gold.withValues(alpha: 0.12)
            : AppTheme.charcoal.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: proficient
              ? AppTheme.gold.withValues(alpha: 0.45)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          Text(
            signed,
            style: AppTextStyles.cinzel(
              color: proficient ? AppTheme.gold : Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.lato(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
