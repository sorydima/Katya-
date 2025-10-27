/// Modern Card Component with Multiple Variants
library;

import 'package:flutter/material.dart';
import 'package:katya/global/design_system.dart';

enum CardVariant {
  elevated,
  outlined,
  filled,
  flat,
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context, isDark),
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
        boxShadow: _getShadows(isDark),
        border: _getBorder(context, isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (color != null) return color!;

    switch (variant) {
      case CardVariant.elevated:
        return isDark ? AppColors.darkCard : AppColors.white;
      case CardVariant.outlined:
        return isDark ? AppColors.darkSurface : AppColors.white;
      case CardVariant.filled:
        return isDark ? AppColors.darkCard : AppColors.grey100;
      case CardVariant.flat:
        return Colors.transparent;
    }
  }

  List<BoxShadow>? _getShadows(bool isDark) {
    if (shadows != null) return shadows;
    if (variant == CardVariant.elevated && !isDark) {
      return const [AppShadows.md];
    }
    return null;
  }

  Border? _getBorder(BuildContext context, bool isDark) {
    if (border != null) return border;
    if (variant == CardVariant.outlined) {
      return Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.grey300,
        width: 1,
      );
    }
    return null;
  }
}

/// List Card - Optimized for list items
class ModernListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ModernListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      variant: CardVariant.flat,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      margin: margin,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const HSpace(AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.isDarkMode ? Colors.white : AppColors.grey900,
                    fontWeight: FontWeight.w600,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const VSpace(AppSpacing.xs),
                  DefaultTextStyle(
                    style: AppTypography.body.copyWith(
                      color: context.isDarkMode ? AppColors.grey400 : AppColors.grey600,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const HSpace(AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Info Card - For displaying information with icon
class ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ModernInfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return ModernCard(
      variant: CardVariant.filled,
      color: backgroundColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: AppIconSize.lg,
            ),
          ),
          const HSpace(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
                if (description != null) ...[
                  const VSpace(AppSpacing.xs),
                  Text(
                    description!,
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.grey500 : AppColors.grey400,
            ),
        ],
      ),
    );
  }
}

/// Stat Card - For displaying statistics
class ModernStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isPositive;

  const ModernStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveColor = color ?? AppColors.primary;

    return ModernCard(
      variant: CardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    size: AppIconSize.sm,
                    color: effectiveColor,
                  ),
                ),
            ],
          ),
          const VSpace(AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: isDark ? Colors.white : AppColors.grey900,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trend != null) ...[
            const VSpace(AppSpacing.xs),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: AppIconSize.xs,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const HSpace(AppSpacing.xs),
                Text(
                  trend!,
                  style: AppTypography.caption.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
