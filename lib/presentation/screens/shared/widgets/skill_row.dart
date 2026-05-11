import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

class SkillRow extends StatelessWidget {
  final String name;
  final String badge;
  final int value;
  final bool proficient;
  final bool fromBackground;
  final VoidCallback? onTap;

  const SkillRow({
    super.key,
    required this.name,
    required this.badge,
    required this.value,
    required this.proficient,
    this.fromBackground = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(
          proficient ? Icons.circle : Icons.circle_outlined,
          size: 11,
          color: proficient
              ? (fromBackground ? AppTheme.gold : AppTheme.crimson)
              : Colors.white,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.lato(
              color: proficient ? Colors.white : Colors.white60,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          badge,
          style: AppTextStyles.lato(color: Colors.white24, fontSize: 10),
        ),
        const SizedBox(width: 10),
        Text(
          value >= 0 ? '+$value' : '$value',
          style: AppTextStyles.cinzel(
            color: proficient ? AppTheme.gold : Colors.white38,
            fontSize: 14,
            fontWeight: proficient ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: row,
              ),
            ),
    );
  }
}
