import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (color ?? AppTheme.gold)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color ?? AppTheme.gold, size: 16),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: AppTextStyles.cinzel(
              color: color ?? AppTheme.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.lato(color: Colors.white60, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return onTap == null ? box : InkWell(onTap: onTap, child: box);
  }
}
