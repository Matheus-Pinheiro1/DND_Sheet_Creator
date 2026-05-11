import 'package:flutter/material.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';

Future<void> showContextInfoDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.ashGray,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              title,
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: AppTextStyles.lato(
                color: Colors.white70,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ContextInfoButton extends StatelessWidget {
  final String title;
  final String body;
  final double size;
  final EdgeInsetsGeometry padding;

  const ContextInfoButton({
    super.key,
    required this.title,
    required this.body,
    this.size = 18,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: padding,
      splashRadius: 18,
      tooltip: title,
      icon: Icon(Icons.info_outline, color: AppTheme.gold, size: size),
      onPressed: () => showContextInfoDialog(
        context,
        title: title,
        body: body,
      ),
    );
  }
}
