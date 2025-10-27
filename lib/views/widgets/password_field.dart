import 'package:flutter/material.dart';
import 'package:katya/utils/password_strength.dart';
import 'package:katya/views/widgets/password_strength_meter.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showStrengthMeter;
  final PasswordStrengthChecker? strengthChecker;
  final bool showRequirements;
  final bool showStrengthBar;
  final bool showStrengthText;
  final double strengthBarHeight;
  final double spacing;
  final bool enabled;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? initialValue;
  final bool autofocus;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool autovalidate;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? focusedBorderWidth;
  final double? errorBorderWidth;

  const PasswordField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.showStrengthMeter = true,
    this.strengthChecker,
    this.showRequirements = true,
    this.showStrengthBar = true,
    this.showStrengthText = true,
    this.strengthBarHeight = 4.0,
    this.spacing = 8.0,
    this.enabled = true,
    this.obscureText = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.keyboardType,
    this.initialValue,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.autovalidate = false,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.fillColor,
    this.filled = false,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.focusedBorderWidth,
    this.errorBorderWidth,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  late TextEditingController _controller;
  late PasswordStrengthChecker _strengthChecker;
  final _defaultStrengthChecker = const PasswordStrengthChecker();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _strengthChecker = widget.strengthChecker ?? _defaultStrengthChecker;
  }

  @override
  void didUpdateWidget(PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null && widget.controller != null) {
        _controller.dispose();
        _controller = widget.controller!;
      } else if (widget.controller == null) {
        _controller = TextEditingController(text: widget.initialValue);
      }
    }
    if (widget.obscureText != oldWidget.obscureText) {
      setState(() {
        _obscureText = widget.obscureText;
      });
    }
    if (widget.strengthChecker != oldWidget.strengthChecker) {
      _strengthChecker = widget.strengthChecker ?? _defaultStrengthChecker;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  String? _validate(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }
    return null;
  }

  void _onChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderSide = BorderSide(
      color: widget.borderColor ?? theme.dividerColor,
      width: widget.borderWidth ?? 1.0,
    );

    final focusedBorderSide = BorderSide(
      color: widget.focusedBorderColor ?? theme.primaryColor,
      width: widget.focusedBorderWidth ?? 2.0,
    );

    final errorBorderSide = BorderSide(
      color: widget.errorBorderColor ?? theme.colorScheme.error,
      width: widget.errorBorderWidth ?? 2.0,
    );

    final borderRadius = BorderRadius.circular(widget.borderRadius ?? 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          autovalidateMode: widget.autovalidate ? AutovalidateMode.onUserInteraction : null,
          validator: _validate,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            contentPadding: widget.contentPadding ?? const EdgeInsets.all(16.0),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIconConstraints,
            suffixIcon: _buildSuffixIcon(theme),
            suffixIconConstraints: widget.suffixIconConstraints,
            filled: widget.filled,
            fillColor: widget.fillColor,
            border: widget.border ?? _buildBorder(borderRadius, borderSide),
            enabledBorder: widget.enabledBorder ?? _buildBorder(borderRadius, borderSide),
            focusedBorder: widget.focusedBorder ?? _buildBorder(borderRadius, focusedBorderSide),
            errorBorder: widget.errorBorder ?? _buildBorder(borderRadius, errorBorderSide),
            disabledBorder: widget.disabledBorder ?? _buildBorder(borderRadius, borderSide),
          ),
        ),
        if (widget.showStrengthMeter && _controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: PasswordStrengthMeter(
              password: _controller.text,
              checker: _strengthChecker,
              showRequirements: widget.showRequirements,
              showStrengthBar: widget.showStrengthBar,
              showStrengthText: widget.showStrengthText,
              barHeight: widget.strengthBarHeight,
              spacing: widget.spacing,
            ),
          ),
      ],
    );
  }

  InputBorder _buildBorder(BorderRadius borderRadius, BorderSide borderSide) {
    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: borderSide,
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: theme.hintColor,
          ),
          onPressed: widget.enabled
              ? () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                }
              : null,
        ),
      ],
    );
  }
}
