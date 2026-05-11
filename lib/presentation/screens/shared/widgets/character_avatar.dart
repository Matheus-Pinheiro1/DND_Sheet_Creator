import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

class CharacterAvatar extends StatelessWidget {
  final String name;
  final String? avatarChoice;
  final double size;
  final VoidCallback? onTap;

  const CharacterAvatar({
    super.key,
    required this.name,
    this.avatarChoice,
    this.size = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (avatarChoice ?? '').trim().isNotEmpty
        ? avatarChoice!.trim()
        : (name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase());

    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.crimson,
        border: Border.all(color: AppTheme.gold, width: 2),
      ),
      child: Center(
        child: Text(
          displayValue,
          style: AppTextStyles.cinzel(
            fontSize: displayValue.runes.length > 1 ? size * 0.34 : size * 0.45,
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: child,
    );
  }
}
