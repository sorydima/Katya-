// Theme Values and Constants
import 'package:flutter/material.dart';

// Spacing
const double kSpacingSmall = 8.0;
const double kSpacingMedium = 16.0;
const double kSpacingLarge = 24.0;
const double kSpacingXLarge = 32.0;

// Border Radius
const double kBorderRadiusSmall = 4.0;
const double kBorderRadiusMedium = 8.0;
const double kBorderRadiusLarge = 12.0;
const double kBorderRadiusXLarge = 16.0;

// Font Sizes
const double kFontSizeSmall = 12.0;
const double kFontSizeMedium = 14.0;
const double kFontSizeLarge = 16.0;
const double kFontSizeXLarge = 18.0;
const double kFontSizeXXLarge = 20.0;

// Font Weights
const FontWeight kFontWeightLight = FontWeight.w300;
const FontWeight kFontWeightRegular = FontWeight.w400;
const FontWeight kFontWeightMedium = FontWeight.w500;
const FontWeight kFontWeightSemiBold = FontWeight.w600;
const FontWeight kFontWeightBold = FontWeight.w700;

// Colors
const Color kPrimaryColor = Color(0xFF1976D2);
const Color kSecondaryColor = Color(0xFFFF9800);
const Color kErrorColor = Color(0xFFD32F2F);
const Color kSuccessColor = Color(0xFF4CAF50);
const Color kWarningColor = Color(0xFFFF9800);

// Light Theme Colors
const Color kLightBackgroundColor = Color(0xFFFAFAFA);
const Color kLightSurfaceColor = Colors.white;
const Color kLightTextPrimaryColor = Colors.black;
const Color kLightTextSecondaryColor = Colors.black87;
const Color kLightTextHintColor = Colors.black54;

// Dark Theme Colors
const Color kDarkBackgroundColor = Color(0xFF121212);
const Color kDarkSurfaceColor = Color(0xFF1E1E1E);
const Color kDarkTextPrimaryColor = Colors.white;
const Color kDarkTextSecondaryColor = Colors.white70;
const Color kDarkTextHintColor = Colors.white54;

// Shadows
const BoxShadow kDefaultShadow = BoxShadow(
  color: Colors.black12,
  blurRadius: 4,
  offset: Offset(0, 2),
);

const BoxShadow kElevatedShadow = BoxShadow(
  color: Colors.black26,
  blurRadius: 8,
  offset: Offset(0, 4),
);

// Animation Durations
const Duration kShortAnimationDuration = Duration(milliseconds: 200);
const Duration kMediumAnimationDuration = Duration(milliseconds: 300);
const Duration kLongAnimationDuration = Duration(milliseconds: 500);

// Button Styles
ButtonStyle kPrimaryButtonStyle = ElevatedButton.styleFrom(
  elevation: 0,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
  ),
);

ButtonStyle kSecondaryButtonStyle = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
  ),
);

// Input Decoration
InputDecoration kDefaultInputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
);

// Card Theme
const ShapeBorder kDefaultCardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusLarge)),
);
