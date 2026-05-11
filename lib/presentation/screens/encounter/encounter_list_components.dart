part of 'encounter_screen.dart';

class _EmptyEncounterView extends StatelessWidget {
  final VoidCallback onAddMonster;
  final VoidCallback onAddPlayer;
  final VoidCallback onNewEncounter;

  const _EmptyEncounterView({
    required this.onAddMonster,
    required this.onAddPlayer,
    required this.onNewEncounter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined,
                size: 72, color: AppTheme.gold.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(
              'Empty Encounter',
              style: AppTextStyles.cinzel(
                  color: Colors.white54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Add monsters from the Monster Compendium\nor add a player character below.',
              style: AppTextStyles.lato(
                  color: Colors.white38, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: onAddMonster,
                  icon: const Icon(Icons.pets_outlined),
                  label: const Text('Add Monster'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddPlayer,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Add Player'),
                ),
                TextButton.icon(
                  onPressed: onNewEncounter,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('New Encounter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EncounterListSheet extends ConsumerWidget {
  const _EncounterListSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(encounterProvider);
    final notifier = ref.read(encounterProvider.notifier);
    final encounters = notifier.encounters;
    final activeId = notifier.activeEncounterId;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Encounters',
                        style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        notifier.createEncounter();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: encounters.length,
                    itemBuilder: (context, index) {
                      final encounter = encounters[index];
                      return _EncounterListTile(
                        encounter: encounter,
                        isActive: encounter.id == activeId,
                        canDelete: encounters.length > 1,
                        onTap: () {
                          notifier.selectEncounter(encounter.id);
                          Navigator.of(context).pop();
                        },
                        onRename: () =>
                            _showRenameDialog(context, notifier, encounter),
                        onDelete: () => _confirmDeleteEncounter(
                          context,
                          notifier,
                          encounter,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    EncounterNotifier notifier,
    EncounterModel encounter,
  ) {
    final ctrl = TextEditingController(text: encounter.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Rename Encounter',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (_) {
            notifier.renameEncounter(encounter.id, ctrl.text);
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.renameEncounter(encounter.id, ctrl.text);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  void _confirmDeleteEncounter(
    BuildContext context,
    EncounterNotifier notifier,
    EncounterModel encounter,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Delete ${encounter.name}?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          'This removes only this encounter.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () {
              notifier.deleteEncounter(encounter.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EncounterListTile extends StatelessWidget {
  final EncounterModel encounter;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _EncounterListTile({
    required this.encounter,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final participantCount = encounter.participants.length;
    final current = encounter.currentParticipant;
    final subtitle = encounter.isEmpty
        ? 'Empty'
        : 'Round ${encounter.currentRound} - $participantCount participant${participantCount == 1 ? '' : 's'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.darkBrown.withValues(alpha: 0.9)
            : AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isActive ? AppTheme.gold.withValues(alpha: 0.65) : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isActive ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isActive ? AppTheme.gold : Colors.white38,
        ),
        title: Text(
          encounter.name,
          style: AppTextStyles.cinzel(
            color: isActive ? AppTheme.gold : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          current == null ? subtitle : '$subtitle - ${current.name} turn',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(
              value: 'delete',
              enabled: canDelete,
              child: Text(
                canDelete ? 'Delete' : 'Delete (last)',
                style: TextStyle(
                  color: canDelete ? Colors.redAccent : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncounterHeader extends StatelessWidget {
  final EncounterModel encounter;
  final EncounterNotifier notifier;

  const _EncounterHeader({required this.encounter, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final alive = encounter.participants.where((p) => !p.isDefeated).length;
    final total = encounter.participants.length;
    final current = encounter.currentParticipant;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.gold.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          // Round + active turn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round ${encounter.currentRound}',
                  style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                if (current != null)
                  Text(
                    '${current.name}\'s turn',
                    style:
                        AppTextStyles.lato(color: Colors.white70, fontSize: 13),
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
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'alive',
                style: AppTextStyles.lato(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
