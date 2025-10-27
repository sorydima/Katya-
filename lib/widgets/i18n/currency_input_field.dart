import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/i18n/regional_settings_service.dart';

/// Виджет для ввода валютных значений с учетом региональных настроек
class CurrencyInputField extends StatefulWidget {
  final double? initialValue;
  final Function(double) onChanged;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool required;
  final String? currencyCode;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const CurrencyInputField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.required = false,
    this.currencyCode,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  late TextEditingController _controller;
  final RegionalSettingsService _regionalService = RegionalSettingsService();
  late String _currentCurrency;

  @override
  void initState() {
    super.initState();
    _currentCurrency = widget.currencyCode ?? _regionalService.currentSettings.currency;
    _controller = TextEditingController(
      text: widget.initialValue != null ? _formatCurrency(widget.initialValue!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return _regionalService.formatCurrency(value, currencyCode: _currentCurrency);
  }

  double? _parseCurrency(String text) {
    if (text.isEmpty) return null;

    // Удаляем все символы кроме цифр, точек и запятых
    final cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Заменяем запятую на точку для парсинга
    final normalizedText = cleanText.replaceAll(',', '.');

    return double.tryParse(normalizedText);
  }

  void _onTextChanged(String text) {
    final value = _parseCurrency(text);
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        _CurrencyInputFormatter(_currentCurrency),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: _currentCurrency,
        border: const OutlineInputBorder(),
      ),
      onChanged: _onTextChanged,
      validator: widget.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              final parsedValue = _parseCurrency(value);
              if (parsedValue == null) {
                return 'Invalid currency format';
              }
              return null;
            }
          : null,
    );
  }
}

/// Форматтер для ввода валютных значений
class _CurrencyInputFormatter extends TextInputFormatter {
  final String currencyCode;

  _CurrencyInputFormatter(this.currencyCode);

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

/// Виджет для отображения валютного значения
class CurrencyDisplayWidget extends StatelessWidget {
  final double value;
  final String? currencyCode;
  final TextStyle? style;
  final bool showSymbol;
  final bool showCode;

  const CurrencyDisplayWidget({
    super.key,
    required this.value,
    this.currencyCode,
    this.style,
    this.showSymbol = true,
    this.showCode = false,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final currency = currencyCode ?? regionalService.currentSettings.currency;

    String formattedValue;
    if (showSymbol && showCode) {
      formattedValue = '${regionalService.formatCurrency(value, currencyCode: currency)} ($currency)';
    } else if (showCode) {
      formattedValue = '${regionalService.formatNumber(value)} $currency';
    } else {
      formattedValue = regionalService.formatCurrency(value, currencyCode: currency);
    }

    return Text(
      formattedValue,
      style: style,
    );
  }
}

/// Виджет для выбора валюты
class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;
  final List<String>? supportedCurrencies;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    this.supportedCurrencies,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final currencies = supportedCurrencies ?? regionalService.supportedRegions.map((r) => r.currency).toSet().toList();

    return DropdownButtonFormField<String>(
      initialValue: selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'Currency',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      items: currencies.map((currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Row(
            children: [
              Text(currency),
              const SizedBox(width: 8),
              Text(
                _getCurrencySymbol(currency),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newCurrency) {
        if (newCurrency != null) {
          onCurrencyChanged(newCurrency);
        }
      },
    );
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'RUB':
        return '₽';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'BRL':
        return 'R\$';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'TRY':
        return '₺';
      case 'ZAR':
        return 'R';
      case 'MXN':
        return '\$';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'NZD':
        return 'NZ\$';
      case 'THB':
        return '฿';
      case 'MYR':
        return 'RM';
      case 'IDR':
        return 'Rp';
      case 'PHP':
        return '₱';
      case 'VND':
        return '₫';
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return '﷼';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع.';
      case 'JOD':
        return 'د.ا';
      case 'LBP':
        return 'ل.ل';
      case 'EGP':
        return '£';
      case 'MAD':
        return 'د.م.';
      case 'TND':
        return 'د.ت';
      case 'DZD':
        return 'د.ج';
      case 'LYD':
        return 'ل.د';
      case 'SDG':
        return 'ج.س.';
      case 'ETB':
        return 'Br';
      case 'KES':
        return 'KSh';
      case 'UGX':
        return 'USh';
      case 'TZS':
        return 'TSh';
      case 'RWF':
        return 'RF';
      case 'BIF':
        return 'FBu';
      case 'DJF':
        return 'Fdj';
      case 'SOS':
        return 'S';
      case 'ERN':
        return 'Nfk';
      case 'MUR':
        return '₨';
      case 'SCR':
        return '₨';
      case 'KMF':
        return 'CF';
      case 'MGA':
        return 'Ar';
      case 'MWK':
        return 'MK';
      case 'ZMW':
        return 'ZK';
      case 'BWP':
        return 'P';
      case 'SZL':
        return 'L';
      case 'LSL':
        return 'L';
      case 'NAD':
        return 'N\$';
      case 'AOA':
        return 'Kz';
      case 'MZN':
        return 'MT';
      case 'ZWL':
        return 'Z\$';
      case 'GHS':
        return '₵';
      case 'NGN':
        return '₦';
      case 'XOF':
        return 'CFA';
      case 'XAF':
        return 'FCFA';
      case 'XPF':
        return '₣';
      default:
        return currencyCode;
    }
  }
}

/// Виджет для отображения курса валют
class ExchangeRateWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;
  final TextStyle? style;

  const ExchangeRateWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exchange Rate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '1 $fromCurrency = ${regionalService.formatNumber(rate)} $toCurrency',
              style: style ?? Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${regionalService.formatDateTime(lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
