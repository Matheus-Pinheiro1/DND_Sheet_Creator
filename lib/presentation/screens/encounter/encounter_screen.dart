import 'dart:async';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/core/utils/dice_calculator.dart';
import 'package:dnd_character_sheet/data/models/encounter_model.dart';
import 'package:dnd_character_sheet/data/models/encounter_participant.dart';
import 'package:dnd_character_sheet/data/remote/monster_dto.dart';
import 'package:dnd_character_sheet/presentation/screens/encounter/encounter_colors.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/app_navigation_drawer.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';
import 'package:dnd_character_sheet/providers/encounter_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'encounter_empty_view.dart';
part 'encounter_list_sheet.dart';
part 'encounter_color_widgets.dart';
part 'encounter_battle_controls.dart';
part 'encounter_participant_card.dart';
part 'encounter_participant_edit_sheet.dart';
part 'encounter_monster_reference.dart';
part 'encounter_add_player_sheet.dart';
part 'encounter_shared_widgets.dart';

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({super.key});

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  final Map<String, GlobalKey> _participantKeys = {};
  String? _lastScrolledParticipantId;
  StreamSubscription<Object>? _saveErrorSubscription;

  @override
  void initState() {
    super.initState();
    _saveErrorSubscription =
        ref.read(encounterProvider.notifier).saveErrors.listen((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save this encounter. Try restarting the app.',
            style: AppTextStyles.lato(color: Colors.white),
          ),
          backgroundColor: AppTheme.ashGray,
        ),
      );
    });
  }

  @override
  void dispose() {
    _saveErrorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encounter = ref.watch(encounterProvider);
    final notifier = ref.read(encounterProvider.notifier);
    final sorted = encounter.sortedParticipants;
    final encounterColor = encounterColorForTag(encounter.colorTag);
    _syncParticipantKeys(encounter.participants);
    _scheduleScrollToActiveParticipant(encounter.currentParticipant?.id);

    final encounterContent = encounter.isEmpty
        ? _EmptyEncounterView(
            onAddMonster: () => context.push('/monsters'),
            onAddPlayer: () => _showAddPlayerSheet(context),
            onNewEncounter: notifier.createEncounter,
            onOpenEncounters: () => _showEncounterListSheet(context),
          )
        : Column(
            children: [
              _EncounterHeader(
                encounter: encounter,
                notifier: notifier,
                onOpenEncounters: () => _showEncounterListSheet(context),
                onAddMonster: () => context.push('/monsters'),
                onAddPlayer: () => _showAddPlayerSheet(context),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final p = sorted[index];
                    final isActive = index == encounter.currentTurnIndex;
                    return Padding(
                      key: _keyForParticipant(p.id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ParticipantCard(
                        participant: p,
                        isActive: isActive,
                        onTap: () =>
                            _showParticipantSheet(context, p, notifier),
                        onJumpToTurn: () => notifier.jumpToParticipant(p.id),
                        onDamage: (v) => notifier.applyDamage(p.id, v),
                        onHeal: (v) => notifier.applyHealing(p.id, v),
                      ),
                    );
                  },
                ),
              ),
            ],
          );

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      drawer: AppNavigationDrawer(
        selectedRoute: '/encounter',
        onNavigate: (route) {
          if (context.mounted) context.go(route);
        },
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(encounter.name, overflow: TextOverflow.ellipsis),
            if (!encounter.isEmpty)
              Text(
                'Round ${encounter.currentRound}',
                style: AppTextStyles.lato(
                  color: encounterColor.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: 'Encounters',
            onPressed: () => _showEncounterListSheet(context),
          ),
          PopupMenuButton<String>(
            tooltip: 'Encounter options',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'new':
                  notifier.createEncounter();
                  break;
                case 'add_player':
                  _showAddPlayerSheet(context);
                  break;
                case 'clear':
                  _confirmReset(context, notifier);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'new',
                child: Text('New Encounter'),
              ),
              const PopupMenuItem(
                value: 'add_player',
                child: Text('Add Player'),
              ),
              PopupMenuItem(
                value: 'clear',
                enabled: !encounter.isEmpty,
                child: Text(
                  encounter.isEmpty
                      ? 'Clear Encounter (empty)'
                      : 'Clear Encounter',
                ),
              ),
            ],
          ),
        ],
      ),
      body: encounterContent,
      bottomNavigationBar: encounter.isEmpty
          ? null
          : _EncounterTurnBar(
              encounter: encounter,
              onPrevious: notifier.previousTurn,
              onNext: notifier.nextTurn,
            ),
    );
  }

  void _scheduleScrollToActiveParticipant(String? participantId) {
    if (participantId == null) {
      _lastScrolledParticipantId = null;
      return;
    }
    if (participantId == _lastScrolledParticipantId) return;

    _lastScrolledParticipantId = participantId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToParticipant(participantId);
    });
  }

  void _scrollToParticipant(String participantId) {
    final participantContext = _participantKeys[participantId]?.currentContext;
    if (participantContext == null) return;

    Scrollable.ensureVisible(
      participantContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  GlobalKey _keyForParticipant(String id) {
    return _participantKeys.putIfAbsent(id, GlobalKey.new);
  }

  void _syncParticipantKeys(List<EncounterParticipant> participants) {
    final participantIds = participants.map((p) => p.id).toSet();
    _participantKeys.removeWhere((id, _) => !participantIds.contains(id));
  }

  void _showEncounterListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () {
              notifier.resetEncounter();
              Navigator.of(ctx).pop();
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddPlayerSheet(
        onAdd: (name, hp, ac) {
          ref.read(encounterProvider.notifier).addPlayerCharacter(
                EncounterParticipant.player(name: name, maxHp: hp, ac: ac),
              );
          if (ctx.mounted) Navigator.of(ctx).pop();
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParticipantEditSheet(
        participant: participant,
        notifier: notifier,
        onOpenMonster: (monsterIndex) async {
          if (ctx.mounted) {
            await Navigator.of(ctx).maybePop();
          }
          if (!context.mounted) return;
          context.push('/monsters/${Uri.encodeComponent(monsterIndex)}');
        },
        onRemove: () {
          notifier.removeParticipant(participant.id);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }
}
