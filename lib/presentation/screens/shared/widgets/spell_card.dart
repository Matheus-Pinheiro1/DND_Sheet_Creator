import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/remote/spell_dto.dart';

class SpellCard extends StatelessWidget {
  final SpellDto spell;
  final bool isConcentrating;
  final VoidCallback? onTap;
  final VoidCallback? onConcentrate;
  final String? sourceText;

  const SpellCard({
    super.key,
    required this.spell,
    this.isConcentrating = false,
    this.onTap,
    this.onConcentrate,
    this.sourceText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isConcentrating
          ? AppTheme.crimson.withValues(alpha: 0.28)
          : AppTheme.ashGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isConcentrating ? Colors.orangeAccent : Colors.white12,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          spell.name,
          style: AppTextStyles.cinzel(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${spell.castingTime} • ${spell.range} • ${spell.duration}\n${spell.school}${spell.ritual ? ' • Ritual' : ''}${spell.concentration ? ' • Concentration' : ''}${sourceText != null && sourceText!.isNotEmpty ? '\n$sourceText' : ''}',
            style: AppTextStyles.lato(
              color: Colors.white70,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
        isThreeLine: true,
        trailing: onConcentrate == null
            ? const Icon(Icons.chevron_right, color: Colors.white38)
            : IconButton(
                icon: Icon(
                  isConcentrating ? Icons.track_changes : Icons.gps_not_fixed,
                  color: isConcentrating ? Colors.orangeAccent : AppTheme.gold,
                ),
                onPressed: onConcentrate,
              ),
      ),
    );
  }
}
