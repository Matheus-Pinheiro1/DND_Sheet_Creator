part of 'monsters_screen.dart';

class _ResultCountStrip extends StatelessWidget {
  final int count;
  final bool hasFilters;

  const _ResultCountStrip({
    required this.count,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count monster${count == 1 ? '' : 's'}',
            style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 4),
            Text(
              '(filtered)',
              style: AppTextStyles.lato(
                color: AppTheme.gold.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonsterCard extends StatelessWidget {
  final MonsterSummaryDto monster;
  final VoidCallback onTap;
  final VoidCallback onAddToEncounter;
  final bool isAdding;

  const _MonsterCard({
    required this.monster,
    required this.onTap,
    required this.onAddToEncounter,
    required this.isAdding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monster.name,
                      style: AppTextStyles.cinzel(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _MetaBadge(
                          label: 'CR ${monster.crLabel}',
                          color: _crColor(monster.challengeRating),
                        ),
                        const SizedBox(width: 6),
                        _MetaBadge(
                          label: _capitalize(monster.type),
                          color: _typeColor(monster.type),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _capitalize(monster.size),
                          style: AppTextStyles.lato(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isAdding ? null : onAddToEncounter,
                icon: isAdding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline, size: 20),
                color: AppTheme.gold.withValues(alpha: 0.7),
                tooltip: 'Add to Encounter',
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static Color _crColor(num cr) {
    if (cr <= 0.5) return const Color(0xFF6DBF6D);
    if (cr <= 4) return const Color(0xFFD4AF37);
    if (cr <= 10) return const Color(0xFFE07A30);
    if (cr <= 16) return const Color(0xFFD04040);
    return const Color(0xFF9B59B6);
  }

  static Color _typeColor(String type) {
    return switch (type) {
      'dragon' => const Color(0xFFE25822),
      'undead' => const Color(0xFF8B9DC3),
      'fiend' => const Color(0xFF8B0000),
      'celestial' => const Color(0xFFFFD700),
      'fey' => const Color(0xFFBA55D3),
      'elemental' => const Color(0xFF20B2AA),
      'aberration' => const Color(0xFF9370DB),
      'construct' => const Color(0xFF708090),
      'giant' => const Color(0xFFCD853F),
      'beast' => const Color(0xFF6B8E23),
      'monstrosity' => const Color(0xFFD2691E),
      'humanoid' => const Color(0xFF4682B4),
      'ooze' => const Color(0xFF3CB371),
      'plant' => const Color(0xFF228B22),
      _ => Colors.white38,
    };
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        label,
        style: AppTextStyles.lato(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
