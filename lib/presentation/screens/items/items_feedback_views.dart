part of 'items_screen.dart';

class _EmptyView extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptyView({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.filter_alt_off_outlined
                  : Icons.inventory_2_outlined,
              color: Colors.white24,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No items match your filters' : 'No items found',
              style: AppTextStyles.cinzel(color: Colors.white38, fontSize: 16),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.crimson, size: 52),
            const SizedBox(height: 16),
            Text(
              'Failed to load items',
              style: AppTextStyles.cinzel(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
