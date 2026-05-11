part of '../tab_features.dart';

class _AdvancementSection extends ConsumerWidget {
  final CharacterModel character;
  const _AdvancementSection({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleAdvancements = [
      ...LevelAdvancementService.visibleOriginEntries(character),
      ...LevelAdvancementService.classLevelEntries(character),
    ];
    final available = LevelAdvancementService.availableCount(
      character.className,
      character.level,
    );
    final used = LevelAdvancementService.spentCount(character);
    final remaining = LevelAdvancementService.remainingCount(character);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ASI / Feats',
                  style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$used / $available chosen',
                  style: AppTextStyles.lato(
                    color: AppTheme.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'At the standard class levels, choose a feat or increase ability scores. Changes here immediately update the character sheet.',
            style: AppTextStyles.lato(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (visibleAdvancements.isEmpty)
            Text(
              'No recorded ASI / feat choices yet.',
              style: AppTextStyles.lato(color: Colors.white38, fontSize: 12),
            )
          else
            ...visibleAdvancements.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _showAdvancementDetail(context, entry),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.charcoal,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatAdvancement(entry),
                            style: AppTextStyles.lato(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.white30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (remaining > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showModalBottomSheet<_AdvancementResult>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppTheme.ashGray,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) =>
                        _AdvancementPickerSheet(character: character),
                  );
                  if (result == null) return;
                  ref
                      .read(charactersProvider.notifier)
                      .updateCharacter(result.character);
                },
                icon: const Icon(Icons.add),
                label: Text(
                  remaining == 1
                      ? 'Choose 1 remaining advancement'
                      : 'Choose $remaining remaining advancements',
                  style: AppTextStyles.cinzel(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'All currently available ASI / feat picks have already been recorded for this character level.',
              style: AppTextStyles.lato(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAdvancement(String value) {
    if (value.startsWith('level:')) {
      return LevelAdvancementService.formatEntry(value);
    }

    if (value.startsWith('origin_asi:')) {
      final raw = value.replaceFirst('origin_asi:', '');
      return 'Origin Ability Bonuses — ${raw.split(',').map((e) => e.toUpperCase()).join(' and ')}';
    }
    if (value.startsWith('origin_feat:')) {
      final featId = value.replaceFirst('origin_feat:', '');
      final feat = ProgressionService.findFeat(featId);
      return 'Origin Feat — ${feat?.name ?? featId}';
    }
    if (value.startsWith('asi:')) {
      final raw = value.replaceFirst('asi:', '');
      return 'Ability Score Improvement — ${raw.split(',').map((e) => e.toUpperCase()).join(' and ')}';
    }
    if (value.startsWith('feat:')) {
      final parts = value.split(':');
      final feat = ProgressionService.findFeat(parts[1]);
      if (ProgressionService.isMagicInitiateId(parts[1])) {
        return 'Feat — ${feat?.name ?? parts[1]}';
      }
      final bonus = parts.length > 2 && parts[2] != '-' && parts[2].isNotEmpty
          ? ' (+1 ${parts[2].toUpperCase()})'
          : '';
      return 'Feat — ${feat?.name ?? parts[1]}$bonus';
    }
    return value;
  }

  void _showAdvancementDetail(BuildContext context, String value) {
    if (value.startsWith('level:')) {
      showFeatureDetailDialog(
        context,
        ClassFeatureModel(
          id: 'advancement-${value.hashCode}',
          name: LevelAdvancementService.detailName(value),
          description: LevelAdvancementService.detailDescription(value),
          availableAtLevel: LevelAdvancementService.levelFromEntry(value) ?? 1,
          tags: const ['Advancement'],
          source: 'feat',
        ),
      );
      return;
    }

    if (value.startsWith('origin_feat:')) {
      final featId = value.replaceFirst('origin_feat:', '');
      final feat = ProgressionService.findFeat(featId);
      if (feat == null) return;
      showFeatureDetailDialog(
        context,
        ClassFeatureModel(
          id: 'origin-${feat.id}',
          name: feat.name,
          description: feat.description,
          availableAtLevel: 1,
          tags: ['Origin', ...feat.tags],
          source: 'feat',
        ),
      );
      return;
    }

    if (value.startsWith('origin_asi:')) {
      final raw = value.replaceFirst('origin_asi:', '');
      showFeatureDetailDialog(
        context,
        ClassFeatureModel(
          id: 'origin-asi-$raw',
          name: 'Origin Ability Bonuses',
          description:
              'This background granted the following ability increases: ${raw.replaceAll(',', ' and ').toUpperCase()}. These bonuses are already reflected in the character sheet.',
          availableAtLevel: 1,
          tags: const ['Origin'],
          source: 'feat',
        ),
      );
      return;
    }

    if (value.startsWith('feat:')) {
      final parts = value.split(':');
      final feat = ProgressionService.findFeat(parts[1]);
      if (feat == null) return;
      String description = feat.description;
      if (ProgressionService.isMagicInitiateId(parts[1])) {
        final ability = parts.length > 2 ? parts[2].toUpperCase() : '';
        final cantrips = parts.length > 3 && parts[3].isNotEmpty
            ? parts[3].split(',').join(', ')
            : '';
        final spell = parts.length > 4 ? parts[4] : '';
        final extras = <String>[];
        if (ability.isNotEmpty) extras.add('Spellcasting ability: $ability');
        if (cantrips.isNotEmpty) extras.add('Cantrips: $cantrips');
        if (spell.isNotEmpty) extras.add('Level 1 spell: $spell');
        if (extras.isNotEmpty) {
          description = '$description\n\n${extras.join('\n')}';
        }
      } else {
        final extras = <String>[];
        if (parts.length > 2 && parts[2].isNotEmpty && parts[2] != '-') {
          extras.add('Applied ability increase: +1 ${parts[2].toUpperCase()}.');
        }
        if (parts.length > 3 && parts[3].isNotEmpty) {
          final details = parts.sublist(3).join(':').split('|');
          for (final detail in details) {
            if (detail.startsWith('skill:')) {
              final skill = detail.replaceFirst('skill:', '');
              final label =
                  _AdvancementPickerSheetState._skillLabels[skill] ?? skill;
              extras.add('Selected skill: $label');
            } else if (detail.startsWith('expertise:')) {
              final skill = detail.replaceFirst('expertise:', '');
              final label =
                  _AdvancementPickerSheetState._skillLabels[skill] ?? skill;
              extras.add('Expertise: $label');
            } else if (detail.startsWith('tool:')) {
              extras.add('Selected tool: ${detail.replaceFirst('tool:', '')}');
            }
          }
        }
        if (extras.isNotEmpty) {
          description = '$description\n\n${extras.join('\n')}';
        }
      }
      showFeatureDetailDialog(
        context,
        ClassFeatureModel(
          id: 'feat-${feat.id}',
          name: feat.name,
          description: description,
          availableAtLevel: 0,
          tags: feat.tags,
          source: 'feat',
        ),
      );
      return;
    }

    if (value.startsWith('asi:')) {
      final raw = value.replaceFirst('asi:', '');
      showFeatureDetailDialog(
        context,
        ClassFeatureModel(
          id: 'asi-$raw',
          name: 'Ability Score Improvement',
          description:
              'This ASI was already applied to the character. Applied values: ${raw.replaceAll(',', ' and ').toUpperCase()}. The ability scores on the sheet already include this bonus.',
          availableAtLevel: 0,
          tags: const ['ASI'],
          source: 'feat',
        ),
      );
    }
  }
}
