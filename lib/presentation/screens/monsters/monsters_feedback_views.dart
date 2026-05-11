part of 'monsters_screen.dart';

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
              hasFilters ? Icons.filter_list_off : Icons.search_off,
              color: Colors.white24,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No monsters match these filters.'
                  : 'No monsters found.',
              style: AppTextStyles.cinzel(color: Colors.white54, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear all filters',
                  style: AppTextStyles.lato(color: AppTheme.gold),
                ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Could not load monsters',
              style: AppTextStyles.cinzel(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.lato(color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
