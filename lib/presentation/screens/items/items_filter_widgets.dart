part of 'items_screen.dart';

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
  final ItemFilters filters;
  final ValueChanged<String> onTypeToggle;
  final ValueChanged<String> onRarityToggle;
  final VoidCallback onAttunementToggle;
  final VoidCallback onClear;

  const _FilterPanel({
    required this.filters,
    required this.onTypeToggle,
    required this.onRarityToggle,
    required this.onAttunementToggle,
    required this.onClear,
  });

  static const _types = [
    ('Weapon', Icons.gavel_outlined),
    ('Armor', Icons.shield_outlined),
    ('Wondrous Item', Icons.auto_awesome_outlined),
    ('Potion', Icons.science_outlined),
    ('Ring', Icons.circle_outlined),
    ('Scroll', Icons.description_outlined),
    ('Staff', Icons.settings_ethernet),
    ('Wand', Icons.electrical_services_outlined),
    ('Rod', Icons.linear_scale_outlined),
    ('Ammunition', Icons.arrow_upward_outlined),
    ('Adventuring Gear', Icons.backpack_outlined),
    ('Tool', Icons.handyman_outlined),
    ('Vehicle', Icons.directions_car_outlined),
    ('Other', Icons.category_outlined),
  ];

  static const _rarities = [
    ('standard', 'Standard'),
    ('common', 'Common'),
    ('uncommon', 'Uncommon'),
    ('rare', 'Rare'),
    ('very rare', 'Very Rare'),
    ('legendary', 'Legendary'),
    ('artifact', 'Artifact'),
    ('epic', 'Epic'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.darkBrown.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Type'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _types.map((t) {
              return _FilterChip(
                label: t.$1,
                icon: t.$2,
                selected: filters.isTypeSelected(t.$1),
                onTap: () => onTypeToggle(t.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _SectionLabel('Rarity'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _rarities.map((r) {
              return _FilterChip(
                label: r.$2,
                selected: filters.isRaritySelected(r.$1),
                color: _rarityFilterColor(r.$1),
                onTap: () => onRarityToggle(r.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _SectionLabel('Attunement'),
          const SizedBox(height: 6),
          _FilterChip(
            label: 'Requires Attunement',
            icon: Icons.link_outlined,
            selected: filters.attunementOnly == true,
            onTap: onAttunementToggle,
          ),
          if (filters.hasActiveFilters) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _rarityFilterColor(String rarity) => switch (rarity) {
        'standard' => Colors.white54,
        'common' => const Color(0xFF808080),
        'uncommon' => const Color(0xFF2ECC71),
        'rare' => const Color(0xFF3498DB),
        'very rare' => const Color(0xFF9B59B6),
        'legendary' => const Color(0xFFE67E22),
        'artifact' => const Color(0xFFE74C3C),
        'epic' => const Color(0xFFE91E8C),
        _ => Colors.white38,
      };
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.lato(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.gold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? c.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c.withValues(alpha: 0.7) : Colors.white24,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? c : Colors.white38),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.lato(
                color: selected ? c : Colors.white54,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
