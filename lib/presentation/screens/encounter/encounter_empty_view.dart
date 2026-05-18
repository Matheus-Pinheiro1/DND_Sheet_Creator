part of 'encounter_screen.dart';

class _EmptyEncounterView extends StatelessWidget {
  final VoidCallback onAddMonster;
  final VoidCallback onAddPlayer;
  final VoidCallback onNewEncounter;
  final VoidCallback onOpenEncounters;

  const _EmptyEncounterView({
    required this.onAddMonster,
    required this.onAddPlayer,
    required this.onNewEncounter,
    required this.onOpenEncounters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 72,
              color: AppTheme.gold.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Empty Encounter',
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add monsters from the Monster Compendium\nor add a player character below.',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
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
                TextButton.icon(
                  onPressed: onOpenEncounters,
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('All Encounters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
