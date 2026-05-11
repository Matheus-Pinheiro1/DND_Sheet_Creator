part of '../step_class.dart';

class _ClassCard extends StatelessWidget {
  final ClassDto cls;
  final bool isSelected;
  final VoidCallback onTap;
  const _ClassCard({
    required this.cls,
    required this.isSelected,
    required this.onTap,
  });

  static const hitDieIcons = {
    8: '🎲 D8',
    6: '🎲 D6',
    10: '🎲 D10',
    12: '🎲 D12'
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.crimson : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.gold : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cls.name,
                      style: AppTextStyles.cinzel(
                        fontSize: 18,
                        color: isSelected ? AppTheme.gold : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.gold),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(
                      hitDieIcons[cls.hitDie] ?? 'Hit Die: d${cls.hitDie}'),
                  if (cls.isSpellcaster) const _InfoChip('✨ Spellcaster'),
                  if (cls.isUnearthedArcana)
                    const _InfoChip('UA - Unearthed Arcana'),
                  _InfoChip('Subclass at Lv ${cls.subclassLevel}'),
                  ...cls.savingThrows
                      .map((save) => _InfoChip('Save: ${save.toUpperCase()}')),
                  ...cls.proficiencies.take(3).map((prof) => _InfoChip(prof)),
                ],
              ),
              if (cls.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  cls.description,
                  style: AppTextStyles.lato(
                    fontSize: 12,
                    color: Colors.white60,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomClassCard extends StatelessWidget {
  final CustomClassModel customClass;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomClassCard({
    required this.customClass,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.crimson : AppTheme.ashGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.gold : AppTheme.gold,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.auto_fix_high, color: AppTheme.gold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customClass.name,
                      style: AppTextStyles.cinzel(
                        color: isSelected ? AppTheme.gold : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'd${customClass.hitDie}${customClass.spellcastingAbility != null ? ' · ${customClass.spellcastingAbility!.toUpperCase()} caster' : ''}',
                      style: AppTextStyles.lato(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (customClass.features.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        customClass.features.take(3).join(' · '),
                        style: AppTextStyles.lato(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Colors.white38,
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.redAccent,
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTheme.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubclassSelector extends ConsumerWidget {
  final String classIndex;
  const _SubclassSelector({required this.classIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subclassesAsync = ref.watch(subclassesProvider(classIndex));
    final state = ref.watch(creationProvider);

    return subclassesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingDragon(label: 'Loading subclasses...'),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'Could not load subclasses right now. Check the connection and try again.',
          style: AppTextStyles.lato(color: Colors.redAccent, fontSize: 12),
        ),
      ),
      data: (subclasses) {
        if (subclasses.isEmpty) {
          return const _MissingSubclassCatalogNotice();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            if (state.subclass.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  'This character is level ${state.level}. Choose a subclass before continuing.',
                  style: AppTextStyles.lato(
                    color: Colors.orange.shade200,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subclass',
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick one now. The sheet will unlock the subclass features automatically as the character gains levels.',
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subclasses.map((sub) {
                final selected = state.subclass == sub['index'];
                return ChoiceChip(
                  label: Text(sub['name'] ?? '', style: AppTextStyles.lato()),
                  selected: selected,
                  selectedColor: AppTheme.crimson,
                  onSelected: (_) {
                    ref.read(creationProvider.notifier).setSubclass(
                          subclass: sub['index'] ?? '',
                          subclassName: sub['name'] ?? '',
                        );
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _MissingSubclassCatalogNotice extends StatelessWidget {
  const _MissingSubclassCatalogNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        'No subclass options are cataloged for this class yet. You can continue; add subclass entries in assets/data/2024/subclasses.json later to unlock subclass selection and feature text.',
        style: AppTextStyles.lato(
          color: Colors.white70,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.cinzel(
          color: AppTheme.gold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CreateCustomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CreateCustomButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.gold,
            style: BorderStyle.solid,
          ),
          color: AppTheme.gold,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.darkBrown, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.cinzel(
                color: AppTheme.darkBrown,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.lato(fontSize: 11, color: Colors.white70),
      ),
    );
  }
}
