import 'package:flutter/material.dart';

/// Compatibility layer for old Flutter TextTheme properties
extension TextThemeCompatibility on TextTheme {
  // Old properties mapped to new ones
  TextStyle? get subtitle1 => titleMedium;
  TextStyle? get subtitle2 => titleSmall;
  TextStyle? get headline6 => titleLarge;
  TextStyle? get headline5 => headlineSmall;
  TextStyle? get headline4 => headlineMedium;
  TextStyle? get headline1 => displayLarge;
  TextStyle? get bodyText1 => bodyLarge;
  TextStyle? get bodyText2 => bodyMedium;
  TextStyle? get caption => bodySmall;
  TextStyle? get button => labelLarge;
}

/// Compatibility layer for old Flutter ThemeData properties
extension ThemeDataCompatibility on ThemeData {
  Color? get selectedRowColor => colorScheme.primary.withOpacity(0.12);
  Color? get errorColor => colorScheme.error;
  Color? get accentColor => colorScheme.secondary;
}
