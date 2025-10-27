import 'package:flutter/material.dart';
import 'package:katya/global/design_system.dart';

enum InputVariant { filled, outlined, underlined }

enum InputSize { small, medium, large }

class ModernInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool isDisabled;
  final String? errorText;
  final Widget? leading;
  final Widget? trailing;
  final InputVariant variant;
  final InputSize size;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;

  const ModernInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.isDisabled = false,
    this.errorText,
    this.leading,
    this.trailing,
    this.variant = InputVariant.filled,
    this.size = InputSize.medium,
    this.onChanged,
    this.onEditingComplete,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<ModernInput> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets contentPadding = _paddingForSize(widget.size);
    final InputBorder border = _borderForVariant(widget.variant, context);
    final InputBorder focusedBorder = _focusedBorderForVariant(widget.variant, context);
    final InputBorder errorBorder = _errorBorderForVariant(widget.variant, context);

    final Widget? suffix = widget.isPassword
        ? IconButton(
            tooltip: _obscure ? 'Show password' : 'Hide password',
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: widget.isDisabled ? null : () => setState(() => _obscure = !_obscure),
          )
        : widget.trailing;

    final decoration = InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      contentPadding: contentPadding,
      prefixIcon: widget.leading,
      suffixIcon: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      errorText: widget.errorText,
    );

    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      obscureText: _obscure,
      enabled: !widget.isDisabled,
      focusNode: widget.focusNode,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      style: _textStyleForSize(widget.size),
      decoration: decoration,
    );
  }

  EdgeInsets _paddingForSize(InputSize size) {
    switch (size) {
      case InputSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case InputSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case InputSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  TextStyle _textStyleForSize(InputSize size) {
    switch (size) {
      case InputSize.small:
        return AppTypography.bodySmall;
      case InputSize.medium:
        return AppTypography.body;
      case InputSize.large:
        return AppTypography.bodyLarge;
    }
  }

  InputBorder _borderForVariant(InputVariant variant, BuildContext context) {
    switch (variant) {
      case InputVariant.filled:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      case InputVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
        );
    }
  }

  InputBorder _focusedBorderForVariant(InputVariant variant, BuildContext context) {
    final Color focusColor = Theme.of(context).colorScheme.primary;
    switch (variant) {
      case InputVariant.filled:
        return OutlineInputBorder(
          borderSide: BorderSide(color: focusColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderSide: BorderSide(color: focusColor, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      case InputVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: focusColor, width: 2),
        );
    }
  }

  InputBorder _errorBorderForVariant(InputVariant variant, BuildContext context) {
    switch (variant) {
      case InputVariant.filled:
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
      case InputVariant.underlined:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        );
    }
  }
}
