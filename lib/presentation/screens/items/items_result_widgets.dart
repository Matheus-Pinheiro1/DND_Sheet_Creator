part of 'items_screen.dart';

class _ResultCountStrip extends StatelessWidget {
  final int count;
  final bool hasFilters;

  const _ResultCountStrip({required this.count, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count item${count == 1 ? '' : 's'}',
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

class _ItemCard extends ConsumerWidget {
  final ItemModel item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = _rarityColor(item.rarity);
    final typeColor = _typeColor(item.itemType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: AppTheme.gold,
          collapsedIconColor: Colors.white24,
          onExpansionChanged: (expanded) {
            if (expanded) {
              ref.read(itemDescriptionProvider(item.id).future);
            }
          },
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _ItemBadge(label: item.itemType, color: typeColor),
                        _ItemBadge(
                          label: item.rarityLabel,
                          color: rarityColor,
                        ),
                        if (item.requiresAttunement)
                          const _ItemBadge(
                            label: 'Attunement',
                            color: Color(0xFF9B59B6),
                          ),
                        if (item.damage != null)
                          _ItemBadge(
                            label: '${item.damage} ${item.damageType ?? ''}'
                                .trim(),
                            color: const Color(0xFFD04040),
                          ),
                        if (item.ac != null)
                          _ItemBadge(
                            label: 'AC ${item.ac}',
                            color: const Color(0xFF4682B4),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.publisher.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text(
                    _shortPublisher(item.publisher),
                    style: AppTextStyles.lato(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          children: [
            _ItemDetailBody(item: item),
          ],
        ),
      ),
    );
  }

  static String _shortPublisher(String pub) {
    const map = {
      'Wizards of the Coast': 'WotC',
      'Loot Tavern': 'Loot Tavern',
      'Kobold Press': 'Kobold Press',
      'Mage Hand Press': 'Mage Hand',
      'Sterling Vermin Adventuring Co.': 'Sterling Vermin',
    };
    return map[pub] ?? (pub.length > 16 ? '${pub.substring(0, 14)}…' : pub);
  }

  static Color _rarityColor(String rarity) => switch (rarity) {
        'standard' => Colors.white38,
        'common' => const Color(0xFF808080),
        'uncommon' => const Color(0xFF2ECC71),
        'rare' => const Color(0xFF3498DB),
        'very rare' => const Color(0xFF9B59B6),
        'legendary' => const Color(0xFFE67E22),
        'artifact' => const Color(0xFFE74C3C),
        'epic' => const Color(0xFFE91E8C),
        _ => Colors.white38,
      };

  static Color _typeColor(String type) => switch (type) {
        'Weapon' => const Color(0xFFE07A30),
        'Armor' => const Color(0xFF4682B4),
        'Wondrous Item' => const Color(0xFFD4AF37),
        'Potion' => const Color(0xFF2ECC71),
        'Ring' => const Color(0xFF9B59B6),
        'Scroll' => const Color(0xFFAB8C5E),
        'Rod' => const Color(0xFF7F8C8D),
        'Staff' => const Color(0xFF795548),
        'Wand' => const Color(0xFF8E44AD),
        'Ammunition' => const Color(0xFF6DBF6D),
        'Adventuring Gear' => const Color(0xFF16A085),
        'Tool' => const Color(0xFF7F8C8D),
        'Vehicle' => const Color(0xFF6B8E23),
        _ => Colors.white38,
      };
}

class _ItemDetailBody extends ConsumerWidget {
  final ItemModel item;

  const _ItemDetailBody({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descAsync = ref.watch(itemDescriptionProvider(item.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.range != null ||
            item.weaponProperties != null ||
            item.mastery != null ||
            item.weight != null ||
            item.cost != null)
          _StatsGrid([
            if (item.range != null) ('Range', item.range!),
            if (item.weaponProperties != null)
              ('Properties', item.weaponProperties!),
            if (item.mastery != null) ('Mastery', item.mastery!),
            if (item.stealth != null) ('Stealth', item.stealth!),
            if (item.weight != null) ('Weight', '${item.weight} lb'),
            if (item.cost != null) ('Cost', '${item.cost} GP'),
          ]),
        const SizedBox(height: 8),
        descAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => Text(
            'Could not load description.',
            style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
                fontStyle: FontStyle.italic),
          ),
          data: (desc) {
            if (desc.isEmpty) {
              return Text(
                'No description available.',
                style: AppTextStyles.lato(
                  color: Colors.white38,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              );
            }
            final cleaned = desc.startsWith(item.name)
                ? desc.substring(item.name.length).trimLeft()
                : desc;
            return Text(
              cleaned,
              style: AppTextStyles.lato(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ItemBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ItemBadge({required this.label, required this.color});

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

class _StatsGrid extends StatelessWidget {
  final List<(String, String)> rows;

  const _StatsGrid(this.rows);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: rows.map((r) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 4),
            child: Text(
              r.$1,
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              r.$2,
              style: AppTextStyles.lato(color: Colors.white70, fontSize: 13),
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
