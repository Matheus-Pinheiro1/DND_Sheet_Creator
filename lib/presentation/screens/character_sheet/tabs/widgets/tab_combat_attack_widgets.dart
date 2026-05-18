part of '../tab_combat.dart';

class _AttacksSection extends StatelessWidget {
  final CharacterModel character;
  final void Function(CharacterModel) onUpdate;

  const _AttacksSection({required this.character, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (character.attacks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'No attacks yet. Tap + to add a weapon or action.',
                style: AppTextStyles.lato(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...character.attacks.asMap().entries.map((entry) {
            return _AttackCard(
              attack: entry.value,
              onEdit: () => _showAttackDialog(
                context,
                existing: entry.value,
                index: entry.key,
              ),
              onDelete: () {
                final list = List<AttackModel>.from(character.attacks)
                  ..removeAt(entry.key);
                onUpdate(character.copyWith(attacks: list));
              },
            );
          }),
        TextButton.icon(
          onPressed: () => _showAttackDialog(context),
          icon: const Icon(Icons.add, color: AppTheme.gold),
          label: Text(
            'Add Attack / Action',
            style: AppTextStyles.cinzel(color: AppTheme.gold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showAttackDialog(
    BuildContext context, {
    AttackModel? existing,
    int? index,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.ashGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AttackFormSheet(
        character: character,
        existing: existing,
        onSave: (attack) {
          final list = List<AttackModel>.from(character.attacks);
          if (index != null) {
            list[index] = attack;
          } else {
            list.add(attack);
          }
          onUpdate(character.copyWith(attacks: list));
        },
      ),
    );
  }
}

class _AttackCard extends StatelessWidget {
  final AttackModel attack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AttackCard({
    required this.attack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.ashGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: attack.isMagic ? Colors.purple : Colors.white12,
          width: attack.isMagic ? 1.5 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(
            _weaponIcon,
            color: attack.isMagic ? Colors.purpleAccent : AppTheme.gold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(attack.name,
                    style: AppTextStyles.cinzel(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
                if (attack.isMagic) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.purpleAccent,
                    size: 14,
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Row(children: [
                _AttackBadge(
                  attack.attackBonus,
                  Icons.gps_fixed,
                  Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                _AttackBadge(
                  '${attack.damageDice} ${attack.damageType}',
                  Icons.whatshot,
                  Colors.redAccent,
                ),
                const SizedBox(width: 8),
                _AttackBadge(
                  attack.range,
                  Icons.social_distance,
                  Colors.blueAccent,
                ),
              ]),
              if (attack.properties.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(attack.properties,
                    style: AppTextStyles.lato(
                      color: Colors.white38,
                      fontSize: 11,
                    )),
              ],
            ],
          )),
          Column(children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: Colors.white38),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ]),
        ]),
      ),
    );
  }

  IconData get _weaponIcon {
    final name = attack.name.toLowerCase();
    if (name.contains('bow') || name.contains('arrow')) {
      return Icons.arrow_forward;
    }
    if (name.contains('spell') ||
        name.contains('fire') ||
        name.contains('bolt')) {
      return Icons.auto_awesome;
    }
    if (name.contains('dagger') || name.contains('knife')) {
      return Icons.push_pin;
    }
    return Icons.sports_martial_arts;
  }
}

class _ClassActionsSection extends ConsumerWidget {
  final CharacterModel character;
  const _ClassActionsSection({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(classFeaturesServiceProvider);

    if (character.className.startsWith('custom_class_')) {
      return const SizedBox.shrink();
    }

    final classAsync = ref.watch(
      classFeatureProgressionProvider(
          (className: character.className, level: character.level)),
    );
    final subclassAsync = ref.watch(
      subclassFeatureProgressionProvider(
          (subclass: character.subclass, level: character.level)),
    );

    return classAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) {
        final fallback = service
            .getFeatureProgressionUpToLevel(
                character.className, character.level)
            .expand((e) => e.features)
            .where((f) => f.showInCombat)
            .toList();
        return _ActionFeatureList(features: fallback);
      },
      data: (classLevels) {
        return subclassAsync.when(
          loading: () => _ActionFeatureList(
            features: classLevels
                .expand((e) => e.features)
                .where((f) => f.showInCombat)
                .toList(),
          ),
          error: (_, __) => _ActionFeatureList(
            features: classLevels
                .expand((e) => e.features)
                .where((f) => f.showInCombat)
                .toList(),
          ),
          data: (subclassLevels) {
            final features = [
              ...classLevels.expand((e) => e.features),
              ...subclassLevels.expand((e) => e.features),
            ].where((f) => f.showInCombat).toList();
            return _ActionFeatureList(features: features);
          },
        );
      },
    );
  }
}

class _ActionFeatureList extends StatelessWidget {
  final List<ClassFeatureModel> features;
  const _ActionFeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No class action features unlocked yet.',
          style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    return Column(
      children: features
          .map(
            (feature) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: AppTheme.ashGray,
              child: ListTile(
                onTap: () => showFeatureDetailDialog(context, feature),
                leading: const Icon(Icons.bolt_outlined, color: AppTheme.gold),
                title: Text(
                  feature.name,
                  style: AppTextStyles.cinzel(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  feature.summary ?? feature.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.lato(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                trailing: SizedBox(
                  width: 96,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (feature.actionType != null)
                        Text(
                          feature.actionType!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.lato(
                            color: AppTheme.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (feature.usage != null)
                        Text(
                          feature.usage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.lato(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AttackBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _AttackBadge(this.text, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 3),
      Text(text,
          style: AppTextStyles.lato(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
    ]);
  }
}
