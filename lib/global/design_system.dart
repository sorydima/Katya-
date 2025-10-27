/// Modern Design System for Katya
/// Centralized design tokens, spacing, typography, and theme utilities
library;

import 'package:flutter/material.dart';

/// Design Tokens - Modern 8pt Grid System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic spacing
  static const double padding = md;
  static const double paddingSmall = sm;
  static const double paddingLarge = lg;
  static const double margin = md;
  static const double gap = md;
}

/// Border Radius System
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 9999.0;

  // Semantic radius
  static const double button = md;
  static const double card = lg;
  static const double dialog = xl;
  static const double avatar = full;
}

/// Typography Scale
class AppTypography {
  static const String fontFamily = 'Poppins';

  // Display styles
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Heading styles
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Special styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
  );
}

/// Shadow & Elevation System
class AppShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0D000000), // 5% black
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color(0x26000000), // 15% black
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  // Colored shadows for emphasis
  static BoxShadow colored(Color color, {double opacity = 0.3}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
  }
}

/// Modern Color Palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF34C7B5);
  static const Color primaryDark = Color(0xFF2BA896);
  static const Color primaryLight = Color(0xFF5FD9C9);

  // Secondary Colors
  static const Color secondary = Color(0xFF6C63FF);
  static const Color secondaryDark = Color(0xFF5449E6);
  static const Color secondaryLight = Color(0xFF8B84FF);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentDark = Color(0xFFE6527D);
  static const Color accentLight = Color(0xFFFF8FB3);

  // Neutral Colors - Light Mode
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color black = Color(0xFF000000);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF3A3A3A);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFF4FC3F7);
  static const Color infoDark = Color(0xFF0288D1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkSurface, darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Animation Durations
class AppDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
}

/// Animation Curves
class AppCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve spring = Curves.easeOutCubic;
}

/// Icon Sizes
class AppIconSize {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Avatar Sizes
class AppAvatarSize {
  static const double xs = 24.0;
  static const double sm = 32.0;
  static const double md = 40.0;
  static const double lg = 56.0;
  static const double xl = 80.0;
  static const double xxl = 120.0;
}

/// Button Heights
class AppButtonHeight {
  static const double sm = 32.0;
  static const double md = 44.0;
  static const double lg = 56.0;
}

/// Z-Index / Elevation Levels
class AppElevation {
  static const double flat = 0;
  static const double raised = 2;
  static const double floating = 4;
  static const double modal = 8;
  static const double dropdown = 12;
  static const double dialog = 16;
  static const double snackbar = 20;
  static const double tooltip = 24;
}

/// Breakpoints for Responsive Design
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1800;
}

/// Utility Extensions
extension BuildContextExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if mobile
  bool get isMobile => screenWidth < AppBreakpoints.mobile;

  /// Check if tablet
  bool get isTablet => screenWidth >= AppBreakpoints.mobile && screenWidth < AppBreakpoints.desktop;

  /// Check if desktop
  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Respect system "reduce motion" preference
  bool get reduceMotion => MediaQuery.of(this).accessibleNavigation;
}

/// Responsive Value Helper
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  if (context.isDesktop && desktop != null) return desktop;
  if (context.isTablet && tablet != null) return tablet;
  return mobile;
}

/// Spacing Widgets
class VSpace extends StatelessWidget {
  final double height;
  const VSpace(this.height, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class HSpace extends StatelessWidget {
  final double width;
  const HSpace(this.width, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

/// Common Spacing Widgets
class SpaceXS extends VSpace {
  const SpaceXS({super.key}) : super(AppSpacing.xs);
}

class SpaceSM extends VSpace {
  const SpaceSM({super.key}) : super(AppSpacing.sm);
}

class SpaceMD extends VSpace {
  const SpaceMD({super.key}) : super(AppSpacing.md);
}

class SpaceLG extends VSpace {
  const SpaceLG({super.key}) : super(AppSpacing.lg);
}

class SpaceXL extends VSpace {
  const SpaceXL({super.key}) : super(AppSpacing.xl);
}
