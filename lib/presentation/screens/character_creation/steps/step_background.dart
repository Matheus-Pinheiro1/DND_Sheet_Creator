import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/models/custom_background_model.dart';
import 'package:dnd_character_sheet/data/remote/background_dto.dart';
import 'package:dnd_character_sheet/data/services/starting_equipment_service.dart';
import 'package:dnd_character_sheet/presentation/screens/custom_options/custom_background_screen.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/dialogs/context_info_dialog.dart';
import 'package:dnd_character_sheet/presentation/screens/shared/widgets/loading_dragon.dart';
import 'package:dnd_character_sheet/providers/character_creation_provider.dart';
import 'package:dnd_character_sheet/providers/custom_options_providers.dart';
import 'package:dnd_character_sheet/providers/dnd_api_providers.dart';

class StepBackground extends ConsumerWidget {
  const StepBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgAsync = ref.watch(backgroundsProvider);
    final customBgs = ref.watch(customBackgroundsProvider);
    final state = ref.watch(creationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Background',
                style: AppTextStyles.cinzel(
                  color: AppTheme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => showContextInfoDialog(
                context,
                title: 'Background',
                body:
                    'In the 2024 rules, a background grants skill proficiencies, ability-score options, a specific Origin Feat, tool training, and starting equipment.',
              ),
              icon: const Icon(Icons.info_outline, color: AppTheme.gold),
            ),
          ],
        ),
        if (customBgs.isNotEmpty) ...[
          const _SectionHeader('🎨 Homebrew Backgrounds'),
          ...customBgs.map(
            (bg) => _CustomBgCard(
              bg: bg,
              isSelected: state.background == 'custom_${bg.id}',
              onTap: () => ref.read(creationProvider.notifier).setBackground(
                    background: 'custom_${bg.id}',
                    backgroundName: bg.name,
                    skillIndices: bg.skillProficiencyIndices,
                  ),
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CustomBackgroundScreen(existing: bg),
                ),
              ),
              onDelete: () => _confirmDelete(context, ref, bg),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _CreateCustomButton(
          label: 'Create Homebrew Background',
          icon: Icons.add,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CustomBackgroundScreen(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OFFICIAL 2024 BACKGROUNDS',
                style: AppTextStyles.lato(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ]),
        ),
        bgAsync.when(
          loading: () => const Center(
              child: LoadingDragon(label: 'Loading backgrounds...')),
          error: (_, __) => _ErrorCard(
            message: 'Failed to load backgrounds.',
            onRetry: () => ref.invalidate(backgroundsProvider),
          ),
          data: (backgrounds) => Column(
            children: backgrounds
                .map(
                  (bg) => _OfficialBackgroundCard(
                    background: bg,
                    isSelected: state.background == bg.index,
                    onTap: () =>
                        ref.read(creationProvider.notifier).setBackground(
                              background: bg.index,
                              backgroundName: bg.name,
                              skillIndices: bg.skillProficiencyIndices,
                              abilityOptions: bg.abilityOptions,
                              featId: bg.featId ?? '',
                              featName: bg.featName ?? '',
                              toolProficiencies: bg.toolProficiencies,
                              equipmentOptions: bg.equipmentOptions,
                            ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomBackgroundModel bg,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Delete ${bg.name}?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          'This homebrew background will be permanently deleted.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customBackgroundsProvider.notifier).delete(bg.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OfficialBackgroundCard extends StatelessWidget {
  final BackgroundDto background;
  final bool isSelected;
  final VoidCallback onTap;

  const _OfficialBackgroundCard({
    required this.background,
    required this.isSelected,
    required this.onTap,
  });

  String _format(String index) {
    return index
        .split('-')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? AppTheme.crimson.withValues(alpha: 0.22) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.gold : Colors.white12,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      background.name,
                      style: AppTextStyles.cinzel(
                        color: isSelected ? AppTheme.gold : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showContextInfoDialog(
                      context,
                      title: background.name,
                      body: _buildDetailText(),
                    ),
                    icon: const Icon(Icons.info_outline, color: AppTheme.gold),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...background.abilityOptions
                      .map((ability) => _Badge(_format(ability))),
                  if ((background.featName ?? '').isNotEmpty)
                    _Badge(background.featName!),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                background.description,
                style: AppTextStyles.lato(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Skills: ${background.skillProficiencyIndices.map(_format).join(', ')}',
                style: AppTextStyles.lato(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              if (background.toolProficiencies.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Tools: ${background.toolProficiencies.join(', ')}',
                  style: AppTextStyles.lato(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildDetailText() {
    final buffer = StringBuffer();
    if (background.description.isNotEmpty) {
      buffer.writeln(background.description);
      buffer.writeln();
    }
    if (background.abilityOptions.isNotEmpty) {
      buffer.writeln(
        'Ability options: ${background.abilityOptions.map(_format).join(', ')}',
      );
    }
    if ((background.featName ?? '').isNotEmpty) {
      buffer.writeln('Origin Feat: ${background.featName}');
    }
    if (background.skillProficiencyIndices.isNotEmpty) {
      buffer.writeln(
        'Skill Proficiencies: ${background.skillProficiencyIndices.map(_format).join(', ')}',
      );
    }
    if (background.toolProficiencies.isNotEmpty) {
      buffer.writeln(
          'Tool Proficiencies: ${background.toolProficiencies.join(', ')}');
    }
    if (background.equipmentOptions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Equipment:');
      for (final option in StartingEquipmentService.parseOptions(
        background.equipmentOptions,
      )) {
        buffer.writeln(option.text);
      }
    }
    return buffer.toString().trim();
  }
}

class _CustomBgCard extends StatelessWidget {
  final CustomBackgroundModel bg;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomBgCard({
    required this.bg,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _format(String index) {
    return index
        .split('-')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected
          ? AppTheme.crimson.withValues(alpha: 0.25)
          : AppTheme.gold.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color:
              isSelected ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.3),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.auto_fix_high, color: AppTheme.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bg.name,
                    style: AppTextStyles.cinzel(
                      color: isSelected ? AppTheme.gold : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Skills: ${bg.skillProficiencyIndices.map(_format).join(', ')}',
                    style: AppTextStyles.lato(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.white38,
              onPressed: onEdit,
              tooltip: 'Edit background',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.redAccent.withValues(alpha: 0.7),
              onPressed: onDelete,
              tooltip: 'Delete background',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.gold, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.lato(color: Colors.white60, fontSize: 11),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
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
            color: AppTheme.gold.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          color: AppTheme.gold.withValues(alpha: 0.05),
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        const SizedBox(height: 32),
        const Icon(Icons.wifi_off, color: Colors.redAccent, size: 48),
        const SizedBox(height: 12),
        Text(message, style: AppTextStyles.lato(color: Colors.white54)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ]),
    );
  }
}
