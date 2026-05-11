import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/utils/dice_calculator.dart';
import 'package:dnd_character_sheet/data/models/encounter_model.dart';
import 'package:dnd_character_sheet/data/models/encounter_participant.dart';
import 'package:dnd_character_sheet/data/remote/monster_dto.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/providers/encounter_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'encounter_list_components.dart';
part 'encounter_participant_card.dart';
part 'encounter_participant_edit_sheet.dart';
part 'encounter_monster_reference.dart';
part 'encounter_add_player_sheet.dart';
part 'encounter_shared_widgets.dart';

const _encounterColorTags = <int>[
  0xFFE53935,
  0xFF43A047,
  0xFF1E88E5,
  0xFFFDD835,
  0xFF8E24AA,
  0xFFFF8F00,
  0xFF00ACC1,
  0xFFD81B60,
  0xFF7CB342,
  0xFF5E35B1,
  0xFF6D4C41,
  0xFFB0BEC5,
];

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({super.key});

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  @override
  Widget build(BuildContext context) {
    final encounter = ref.watch(encounterProvider);
    final notifier = ref.read(encounterProvider.notifier);
    final sorted = encounter.sortedParticipants;

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(encounter.name, overflow: TextOverflow.ellipsis),
            if (!encounter.isEmpty)
              Text(
                'Round ${encounter.currentRound}',
                style: AppTextStyles.lato(color: Colors.white54, fontSize: 11),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: 'Encounters',
            onPressed: () => _showEncounterListSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Encounter',
            onPressed: notifier.createEncounter,
          ),
          if (!encounter.isEmpty) ...[
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: 'Add Player',
              onPressed: () => _showAddPlayerSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Encounter',
              onPressed: () => _confirmReset(context, notifier),
            ),
          ],
        ],
      ),
      body: encounter.isEmpty
          ? _EmptyEncounterView(
              onAddMonster: () => context.push('/monsters'),
              onAddPlayer: () => _showAddPlayerSheet(context),
              onNewEncounter: notifier.createEncounter,
            )
          : Column(
              children: [
                _EncounterHeader(encounter: encounter, notifier: notifier),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final p = sorted[index];
                      final isActive = index == encounter.currentTurnIndex &&
                          !encounter.isEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ParticipantCard(
                          participant: p,
                          isActive: isActive,
                          onTap: () =>
                              _showParticipantSheet(context, p, notifier),
                          onDamage: (v) => notifier.applyDamage(p.id, v),
                          onHeal: (v) => notifier.applyHealing(p.id, v),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: encounter.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (encounter.isStarted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FloatingActionButton.small(
                      heroTag: 'prev_turn',
                      backgroundColor: AppTheme.ashGray,
                      onPressed: notifier.previousTurn,
                      child: const Icon(Icons.skip_previous_rounded,
                          color: Colors.white54),
                    ),
                  ),
                FloatingActionButton.extended(
                  heroTag: 'next_turn',
                  backgroundColor: AppTheme.crimson,
                  icon: const Icon(Icons.skip_next_rounded),
                  label: Text(
                    'Next Turn',
                    style: AppTextStyles.cinzel(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: notifier.nextTurn,
                ),
              ],
            ),
    );
  }

  void _showEncounterListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EncounterListSheet(),
    );
  }

  void _confirmReset(BuildContext context, EncounterNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text('Clear Encounter?',
            style: AppTextStyles.cinzel(color: AppTheme.gold)),
        content: Text(
          'This will remove all participants and reset the round counter.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () {
              notifier.resetEncounter();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddPlayerSheet(
        onAdd: (name, hp, ac) {
          ref.read(encounterProvider.notifier).addPlayerCharacter(
                EncounterParticipant.player(name: name, maxHp: hp, ac: ac),
              );
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showParticipantSheet(
    BuildContext context,
    EncounterParticipant participant,
    EncounterNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParticipantEditSheet(
        participant: participant,
        notifier: notifier,
        onRemove: () {
          notifier.removeParticipant(participant.id);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
