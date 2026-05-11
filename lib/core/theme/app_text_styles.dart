import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const List<String> _serifFallback = [
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  static const List<String> _sansFallback = [
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  static TextStyle cinzel({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      fontFamilyFallback: _serifFallback,
    );
  }

  static TextStyle lato({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing,
      fontFamilyFallback: _sansFallback,
    );
  }
}
