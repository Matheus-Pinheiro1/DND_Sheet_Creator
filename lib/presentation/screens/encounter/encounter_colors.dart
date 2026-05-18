import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const legacyBlackEncounterColorTag = 0xFF000000;
const visibleGrayEncounterColorTag = 0xFFE0E0E0;

const encounterColorTags = <int>[
  0xFFE53935,
  0xFF43A047,
  0xFF1E88E5,
  0xFFFDD835,
  0xFF4BF401,
  0xFF8E24AA,
  0xFFFF8F00,
  0xFF00ACC1,
  0xFFD81B60,
  0xFF7CB342,
  0xFF5E35B1,
  0xFF6D4C41,
  0xFFB0BEC5,
  visibleGrayEncounterColorTag,
];

Color encounterColorForTag(int colorTag) {
  if (colorTag == legacyBlackEncounterColorTag) {
    return const Color(visibleGrayEncounterColorTag);
  }
  return colorTag == 0 ? AppTheme.gold : Color(colorTag);
}
