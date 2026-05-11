import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

class LoadingDragon extends StatelessWidget {
  final String label;
  final double size;
  const LoadingDragon({super.key, this.label = 'Loading...', this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🐉', style: TextStyle(fontSize: size))
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 700.ms)
              .then(delay: 200.ms)
              .fadeOut(duration: 700.ms),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.cinzel(
              color: AppTheme.gold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
