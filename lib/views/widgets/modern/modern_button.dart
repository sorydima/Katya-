/// Modern Button Component with Multiple Variants
library;

import 'package:flutter/material.dart';
import 'package:katya/global/design_system.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool disabled;
  final Widget? icon;
  final bool fullWidth;
  final BorderRadius? borderRadius;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.fullWidth = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading || onPressed == null;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: (context.reduceMotion)
          ? _buildButton(context, isDisabled)
          : AnimatedContainer(
              duration: AppDurations.fast,
              child: _buildButton(context, isDisabled),
            ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return AppButtonHeight.sm;
      case ButtonSize.medium:
        return AppButtonHeight.md;
      case ButtonSize.large:
        return AppButtonHeight.lg;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(context, isDisabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case ButtonVariant.outline:
        return _buildOutlineButton(context, isDisabled);
      case ButtonVariant.ghost:
        return _buildGhostButton(context, isDisabled);
      case ButtonVariant.danger:
        return _buildDangerButton(context, isDisabled);
      case ButtonVariant.success:
        return _buildSuccessButton(context, isDisabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey300 : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: isDisabled ? 0 : AppElevation.raised,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, Colors.white),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey200 : AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: isDisabled ? 0 : AppElevation.raised,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, Colors.white),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    final color = isDisabled ? AppColors.grey400 : AppColors.primary;

    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, color),
    );
  }

  Widget _buildGhostButton(BuildContext context, bool isDisabled) {
    final color = isDisabled ? AppColors.grey400 : AppColors.primary;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, color),
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey300 : AppColors.error,
        foregroundColor: Colors.white,
        elevation: isDisabled ? 0 : AppElevation.raised,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, Colors.white),
    );
  }

  Widget _buildSuccessButton(BuildContext context, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.grey300 : AppColors.success,
        foregroundColor: Colors.white,
        elevation: isDisabled ? 0 : AppElevation.raised,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: _buildButtonContent(context, Colors.white),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color color) {
    if (loading) {
      return SizedBox(
        width: _getFontSize() + 4,
        height: _getFontSize() + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(color: color, size: _getFontSize() + 4),
            child: icon!,
          ),
          const HSpace(AppSpacing.sm),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}

/// Icon Button Variant
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final String? tooltip;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon),
      onPressed: disabled ? null : onPressed,
      iconSize: _getIconSize(),
      color: _getColor(),
      style: IconButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppIconSize.sm;
      case ButtonSize.medium:
        return AppIconSize.md;
      case ButtonSize.large:
        return AppIconSize.lg;
    }
  }

  Color _getColor() {
    if (disabled) return AppColors.grey400;

    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.danger:
        return AppColors.error;
      case ButtonVariant.success:
        return AppColors.success;
      default:
        return AppColors.grey700;
    }
  }

  Color? _getBackgroundColor() {
    if (variant == ButtonVariant.ghost) return Colors.transparent;
    if (disabled) return AppColors.grey200;
    return null;
  }
}
