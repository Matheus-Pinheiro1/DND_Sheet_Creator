part of '../step_spells.dart';

class _GrantedSpellsPreview extends StatelessWidget {
  final String title;
  final String subclassName;
  final Map<int, List<String>>? subclassMap;
  final String speciesName;
  final Map<int, List<String>>? speciesMap;

  const _GrantedSpellsPreview({
    required this.title,
    required this.subclassName,
    required this.subclassMap,
    required this.speciesName,
    required this.speciesMap,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    void addSection(String label, Map<int, List<String>>? data) {
      if (data == null || data.isEmpty) return;
      final levels = data.keys.toList()..sort();
      sections.add(
        Text(
          label,
          style: AppTextStyles.cinzel(
            color: AppTheme.gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      sections.add(const SizedBox(height: 6));
      for (final unlock in levels) {
        final spells = data[unlock] ?? const <String>[];
        sections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Level $unlock: ${spells.join(', ')}',
              style: AppTextStyles.lato(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        );
      }
      sections.add(const SizedBox(height: 8));
    }

    addSection(
      subclassName.isEmpty ? 'Subclass' : subclassName,
      subclassMap,
    );
    addSection(
      speciesName.isEmpty ? 'Species' : speciesName,
      speciesMap,
    );

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "These spells are added automatically and don't count against the number of spells you prepare.",
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ...sections,
        ],
      ),
    );
  }
}

class _SpellSelectionTile extends ConsumerStatefulWidget {
  final SpellDto spell;
  final int maxSpellLevel;
  final int currentCantrips;
  final int currentLeveled;
  final int maxCantrips;
  final int maxLeveled;

  const _SpellSelectionTile({
    required this.spell,
    required this.maxSpellLevel,
    required this.currentCantrips,
    required this.currentLeveled,
    required this.maxCantrips,
    required this.maxLeveled,
  });

  @override
  ConsumerState<_SpellSelectionTile> createState() =>
      _SpellSelectionTileState();
}

class _SpellSelectionTileState extends ConsumerState<_SpellSelectionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spell = widget.spell;
    final state = ref.watch(creationProvider);
    final isSelected = state.selectedSpells.contains(spell.index);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.crimson.withValues(alpha: 0.20)
            : AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.gold : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggle(context, isSelected),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.gold : Colors.white30,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                spell.name,
                                style: AppTextStyles.cinzel(
                                  color:
                                      isSelected ? AppTheme.gold : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _Tag(
                              spell.school
                                  .substring(0, spell.school.length.clamp(0, 3))
                                  .toUpperCase(),
                              Colors.blueGrey,
                            ),
                            if (spell.ritual)
                              const _Tag('R', Colors.purpleAccent),
                            if (spell.concentration)
                              const _Tag('C', Colors.orangeAccent),
                            if (spell.damageType != null)
                              const _Tag('DMG', Colors.redAccent),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          spell.level == 0
                              ? '${spell.school} Cantrip • ${spell.castingTime}'
                              : 'Level ${spell.level} ${spell.school} • ${spell.castingTime}',
                          style: AppTextStyles.lato(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleExpanded,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white54,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12, height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _InfoChip('Range', spell.range),
                      _InfoChip('Duration', spell.duration),
                      _InfoChip('Components', spell.components.join(', ')),
                      if (spell.castingTime.isNotEmpty)
                        _InfoChip('Cast', spell.castingTime),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    spell.desc,
                    style: AppTextStyles.lato(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.55,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((spell.higherLevel ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'At Higher Levels: ${spell.higherLevel}',
                      style: AppTextStyles.lato(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.45,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(BuildContext context, bool isSelected) {
    if (isSelected) {
      ref.read(creationProvider.notifier).toggleSpell(widget.spell.index);
      return;
    }
    if (widget.spell.level > widget.maxSpellLevel && widget.spell.level != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can only choose spells of level ${widget.maxSpellLevel} or lower right now.',
          ),
        ),
      );
      return;
    }
    if (widget.spell.level == 0 &&
        widget.currentCantrips >= widget.maxCantrips) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You already selected the maximum number of cantrips (${widget.maxCantrips}).',
          ),
        ),
      );
      return;
    }
    if (widget.spell.level > 0 && widget.currentLeveled >= widget.maxLeveled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You already selected the maximum number of leveled spells (${widget.maxLeveled}).',
          ),
        ),
      );
      return;
    }
    ref.read(creationProvider.notifier).toggleSpell(widget.spell.index);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, ctrl) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 24;
          return SingleChildScrollView(
            controller: ctrl,
            padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.spell.name,
                  style: AppTextStyles.cinzel(
                    fontSize: 22,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.spell.level == 0
                      ? '${widget.spell.school} Cantrip'
                      : 'Level ${widget.spell.level} ${widget.spell.school}',
                  style: AppTextStyles.lato(color: Colors.white54),
                ),
                const Divider(height: 24, color: Colors.white12),
                _Row('Casting Time', widget.spell.castingTime),
                _Row('Range', widget.spell.range),
                _Row('Duration', widget.spell.duration),
                _Row('Components', widget.spell.components.join(', ')),
                const SizedBox(height: 12),
                Text(
                  'Description',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.spell.desc,
                  style: AppTextStyles.lato(
                    color: Colors.white70,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
                if (widget.spell.higherLevel != null &&
                    widget.spell.higherLevel!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'At Higher Levels',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.spell.higherLevel!,
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: AppTextStyles.lato(color: Colors.white38, fontSize: 11),
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.lato(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OriginFeatSpellTile extends StatelessWidget {
  final SpellDto spell;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitleOverride;

  const _OriginFeatSpellTile({
    required this.spell,
    required this.isSelected,
    required this.onTap,
    this.subtitleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.crimson.withValues(alpha: 0.22)
            : AppTheme.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.gold : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          spell.name,
          style: AppTextStyles.cinzel(
            color: isSelected ? AppTheme.gold : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          spell.level == 0
              ? '${spell.school} Cantrip'
              : 'Level ${spell.level} ${spell.school}',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
        ),
        trailing: Icon(
          isSelected ? Icons.check_circle : Icons.add_circle_outline,
          color: isSelected ? AppTheme.gold : Colors.white30,
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, color: Colors.redAccent, size: 48),
        const SizedBox(height: 12),
        Text(
          message,
          style: AppTextStyles.cinzel(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.lato(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const _InfoMessage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.cinzel(
                color: Colors.white54,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
