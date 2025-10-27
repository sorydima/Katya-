import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/i18n/regional_settings_service.dart';

/// Виджет для ввода числовых значений с учетом региональных настроек
class RegionalNumberInputField extends StatefulWidget {
  final double? initialValue;
  final Function(double) onChanged;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool allowDecimals;
  final double? minValue;
  final double? maxValue;

  const RegionalNumberInputField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.allowDecimals = true,
    this.minValue,
    this.maxValue,
  });

  @override
  State<RegionalNumberInputField> createState() => _RegionalNumberInputFieldState();
}

class _RegionalNumberInputFieldState extends State<RegionalNumberInputField> {
  late TextEditingController _controller;
  final RegionalSettingsService _regionalService = RegionalSettingsService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null ? _formatNumber(widget.initialValue!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return _regionalService.formatNumber(value);
  }

  double? _parseNumber(String text) {
    if (text.isEmpty) return null;

    // Удаляем все символы кроме цифр, точек и запятых
    final cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Заменяем запятую на точку для парсинга
    final normalizedText = cleanText.replaceAll(',', '.');

    return double.tryParse(normalizedText);
  }

  void _onTextChanged(String text) {
    final value = _parseNumber(text);
    if (value != null) {
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      keyboardType: widget.allowDecimals
          ? const TextInputType.numberWithOptions(decimal: true)
          : const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        _NumberInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.numbers),
        border: const OutlineInputBorder(),
      ),
      onChanged: _onTextChanged,
      validator: widget.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              final parsedValue = _parseNumber(value);
              if (parsedValue == null) {
                return 'Invalid number format';
              }
              if (widget.minValue != null && parsedValue < widget.minValue!) {
                return 'Value must be at least ${widget.minValue}';
              }
              if (widget.maxValue != null && parsedValue > widget.maxValue!) {
                return 'Value must be at most ${widget.maxValue}';
              }
              return null;
            }
          : null,
    );
  }
}

/// Форматтер для ввода числовых значений
class _NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Простая валидация - разрешаем только цифры, точки и запятые
    final regex = RegExp(r'^[\d.,]*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}

/// Виджет для отображения числового значения
class NumberDisplayWidget extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String? format;
  final bool showThousandsSeparator;

  const NumberDisplayWidget({
    super.key,
    required this.value,
    this.style,
    this.format,
    this.showThousandsSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    String formattedValue;

    formattedValue = regionalService.formatNumber(value);

    return Text(
      formattedValue,
      style: style,
    );
  }
}

/// Виджет для отображения процентов
class PercentageDisplayWidget extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int decimalPlaces;

  const PercentageDisplayWidget({
    super.key,
    required this.value,
    this.style,
    this.decimalPlaces = 1,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final formattedValue = regionalService.formatPercentage(value);

    return Text(
      formattedValue,
      style: style,
    );
  }
}

/// Виджет для ввода процентов
class PercentageInputField extends StatefulWidget {
  final double? initialValue;
  final Function(double) onChanged;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final double? minValue;
  final double? maxValue;

  const PercentageInputField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.minValue,
    this.maxValue,
  });

  @override
  State<PercentageInputField> createState() => _PercentageInputFieldState();
}

class _PercentageInputFieldState extends State<PercentageInputField> {
  late TextEditingController _controller;
  final RegionalSettingsService _regionalService = RegionalSettingsService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null ? _formatPercentage(widget.initialValue!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPercentage(double value) {
    return _regionalService.formatPercentage(value);
  }

  double? _parsePercentage(String text) {
    if (text.isEmpty) return null;

    // Удаляем символ процента и все символы кроме цифр, точек и запятых
    final cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Заменяем запятую на точку для парсинга
    final normalizedText = cleanText.replaceAll(',', '.');

    return double.tryParse(normalizedText);
  }

  void _onTextChanged(String text) {
    final value = _parsePercentage(text);
    if (value != null) {
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        _NumberInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.percent),
        suffixText: '%',
        border: const OutlineInputBorder(),
      ),
      onChanged: _onTextChanged,
      validator: widget.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              final parsedValue = _parsePercentage(value);
              if (parsedValue == null) {
                return 'Invalid percentage format';
              }
              if (widget.minValue != null && parsedValue < widget.minValue!) {
                return 'Value must be at least ${widget.minValue}%';
              }
              if (widget.maxValue != null && parsedValue > widget.maxValue!) {
                return 'Value must be at most ${widget.maxValue}%';
              }
              return null;
            }
          : null,
    );
  }
}

/// Виджет для отображения статистики с числами
class StatisticsWidget extends StatelessWidget {
  final List<StatisticItem> items;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const StatisticsWidget({
    super.key,
    required this.items,
    this.title,
    this.titleStyle,
    this.valueStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
            ],
            ...items.map((item) => _buildStatisticRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(BuildContext context, StatisticItem item) {
    final regionalService = RegionalSettingsService();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            item.formatValue(regionalService),
            style: valueStyle ??
                Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ],
      ),
    );
  }
}

/// Модель для элемента статистики
class StatisticItem {
  final String label;
  final double value;
  final StatisticType type;
  final String? format;
  final String? currency;

  const StatisticItem({
    required this.label,
    required this.value,
    required this.type,
    this.format,
    this.currency,
  });

  String formatValue(RegionalSettingsService regionalService) {
    switch (type) {
      case StatisticType.number:
        return regionalService.formatNumber(value);
      case StatisticType.currency:
        return regionalService.formatCurrency(value, currencyCode: currency);
      case StatisticType.percentage:
        return regionalService.formatPercentage(value);
      case StatisticType.raw:
        return value.toString();
    }
  }
}

/// Типы статистики
enum StatisticType {
  number,
  currency,
  percentage,
  raw,
}
