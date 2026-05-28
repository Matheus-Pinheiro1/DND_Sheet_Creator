part of 'encounter_screen.dart';

class _EncounterHeader extends StatelessWidget {
  final EncounterModel encounter;
  final EncounterNotifier notifier;
  final VoidCallback onOpenEncounters;
  final VoidCallback onAddMonster;
  final VoidCallback onAddPlayer;

  const _EncounterHeader({
    required this.encounter,
    required this.notifier,
    required this.onOpenEncounters,
    required this.onAddMonster,
    required this.onAddPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final alive = encounter.participants.where((p) => !p.isDefeated).length;
    final total = encounter.participants.length;
    final current = encounter.currentParticipant;
    final encounterColor = encounterColorForTag(encounter.colorTag);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: encounterColor.withValues(alpha: 0.38),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _EncounterColorIndicator(
                colorTag: encounter.colorTag,
                isActive: true,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Round ${encounter.currentRound}',
                      style: AppTextStyles.cinzel(
                        color: encounterColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (current != null)
                      Text(
                        '${current.name}\'s turn',
                        style: AppTextStyles.lato(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$alive / $total',
                    style: AppTextStyles.cinzel(
                      color: alive == total ? Colors.white70 : AppTheme.crimson,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'alive',
                    style:
                        AppTextStyles.lato(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenEncounters,
                icon: const Icon(Icons.list_alt_outlined, size: 16),
                label: const Text('All Encounters'),
              ),
              OutlinedButton.icon(
                onPressed: onAddMonster,
                icon: const Icon(Icons.pets_outlined, size: 16),
                label: const Text('Add Monster'),
              ),
              OutlinedButton.icon(
                onPressed: onAddPlayer,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Add Player'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EncounterTurnBar extends StatelessWidget {
  final EncounterModel encounter;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _EncounterTurnBar({
    required this.encounter,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final current = encounter.currentParticipant;
    final turnOrder = encounter.turnParticipants;
    final nextParticipant = turnOrder.isEmpty
        ? null
        : encounter.currentTurnIndex < 0
            ? turnOrder.first
            : turnOrder.length < 2
                ? null
                : turnOrder[
                    (encounter.currentTurnIndex + 1) % turnOrder.length];
    final canUseTurns = turnOrder.isNotEmpty;
    final canGoBack = canUseTurns &&
        (encounter.currentRound > 1 || encounter.currentTurnIndex > 0);
    final nextLabel = encounter.isStarted ? 'Next Turn' : 'Start';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          border: const Border(top: BorderSide(color: Colors.white12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton.outlined(
              tooltip: 'Previous turn',
              onPressed: canGoBack ? onPrevious : null,
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round ${encounter.currentRound}',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current == null ? 'No active turn' : current.name,
                    style: AppTextStyles.lato(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nextParticipant != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      encounter.currentTurnIndex < 0
                          ? 'First: ${nextParticipant.name}'
                          : 'Next: ${nextParticipant.name}',
                      style: AppTextStyles.lato(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: canUseTurns ? onNext : null,
              icon: const Icon(Icons.skip_next_rounded, size: 18),
              label: Text(nextLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.crimson,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
