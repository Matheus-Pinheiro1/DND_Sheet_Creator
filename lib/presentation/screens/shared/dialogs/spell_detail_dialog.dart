import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/remote/spell_dto.dart';

Future<void> showSpellDetailDialog(BuildContext context, SpellDto spell) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.ashGray,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.94,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.all(24),
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
              spell.name,
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(spell.level == 0 ? 'Cantrip' : 'Level ${spell.level}'),
                _Chip(spell.school),
                _Chip(spell.castingTime),
                if (spell.ritual) const _Chip('Ritual'),
                if (spell.concentration) const _Chip('Concentration'),
              ],
            ),
            const SizedBox(height: 16),
            _FactRow('Range', spell.range),
            _FactRow('Duration', spell.duration),
            _FactRow('Components', spell.components.join(', ')),
            if (spell.damageType != null && spell.damageType!.isNotEmpty)
              _FactRow('Damage', spell.damageType!),
            const Divider(height: 28),
            Text('Description',
                style: AppTextStyles.cinzel(
                    color: AppTheme.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(spell.desc,
                style: AppTextStyles.lato(
                    color: Colors.white70, fontSize: 14, height: 1.55)),
            if ((spell.higherLevel ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('At Higher Levels',
                  style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(spell.higherLevel!,
                  style: AppTextStyles.lato(
                      color: Colors.white70, fontSize: 14, height: 1.55)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Text(text,
          style: AppTextStyles.lato(
              color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  const _FactRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: AppTextStyles.lato(color: Colors.white38, fontSize: 12)),
          ),
          Expanded(
              child: Text(value,
                  style:
                      AppTextStyles.lato(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
