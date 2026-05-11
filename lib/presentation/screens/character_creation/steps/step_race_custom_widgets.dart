part of 'step_race.dart';

class _CustomRaceCard extends StatelessWidget {
  final CustomRaceModel race;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomRaceCard({
    required this.race,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? AppTheme.crimson.withValues(alpha: 0.25)
          : AppTheme.gold.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color:
              isSelected ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(
              Icons.auto_fix_high,
              color: AppTheme.gold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    race.name,
                    style: AppTextStyles.cinzel(
                      color: isSelected ? AppTheme.gold : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${race.speed} ft Â· ${race.size}',
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.white38,
              onPressed: onEdit,
              tooltip: 'Edit species',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.redAccent.withValues(alpha: 0.7),
              onPressed: onDelete,
              tooltip: 'Delete species',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.gold, size: 20),
          ]),
        ),
      ),
    );
  }
}
