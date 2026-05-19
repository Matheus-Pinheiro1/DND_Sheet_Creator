part of 'monsters_screen.dart';

class _FilterToggleButton extends StatelessWidget {
  final bool isOpen;
  final int activeCount;
  final VoidCallback onTap;

  const _FilterToggleButton({
    required this.isOpen,
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: isOpen
              ? AppTheme.crimson.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                isOpen ? Icons.filter_list_off : Icons.filter_list,
                color: activeCount > 0 ? AppTheme.gold : Colors.white54,
              ),
            ),
          ),
        ),
        if (activeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppTheme.crimson,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final MonsterFilters filters;
  final void Function(CrRange) onCrToggle;
  final void Function(String) onTypeToggle;
  final void Function(String) onSizeToggle;
  final VoidCallback onClear;

  const _FilterPanel({
    required this.filters,
    required this.onCrToggle,
    required this.onTypeToggle,
    required this.onSizeToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterSection(
            label: 'Challenge Rating',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: CrRange.presets.map((preset) {
                  final selected = filters.isCrPresetSelected(preset);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: preset.label,
                      selected: selected,
                      onTap: () => onCrToggle(preset),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const _SectionDivider(),

          // Type
          _FilterSection(
            label: 'Type',
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kMonsterTypes.map((type) {
                  final selected = filters.types.contains(type);
                  return _FilterChip(
                    label: _capitalize(type),
                    selected: selected,
                    onTap: () => onTypeToggle(type),
                  );
                }).toList(),
              ),
            ),
          ),

          const _SectionDivider(),

          // Size
          _FilterSection(
            label: 'Size',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: kMonsterSizes.map((size) {
                  final selected = filters.sizes.contains(size);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: _capitalize(size),
                      selected: selected,
                      onTap: () => onSizeToggle(size),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (filters.hasActiveFilters)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
                child: TextButton.icon(
                  onPressed: onClear,
                  icon:
                      const Icon(Icons.clear, size: 14, color: Colors.white54),
                  label: Text(
                    'Clear filters',
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _FilterSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.crimson : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.crimson
                : AppTheme.gold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.lato(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
