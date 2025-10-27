import 'package:flutter/material.dart';

import '../../services/i18n/regional_settings_service.dart';

/// Виджет для выбора региона
class RegionalSettingsWidget extends StatefulWidget {
  final Function(RegionalSettings)? onSettingsChanged;
  final RegionalSettings? initialSettings;

  const RegionalSettingsWidget({
    super.key,
    this.onSettingsChanged,
    this.initialSettings,
  });

  @override
  State<RegionalSettingsWidget> createState() => _RegionalSettingsWidgetState();
}

class _RegionalSettingsWidgetState extends State<RegionalSettingsWidget> {
  final RegionalSettingsService _regionalService = RegionalSettingsService();
  late RegionalSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.initialSettings ?? _regionalService.currentSettings;

    // Подписываемся на изменения настроек
    _regionalService.settingsChangeStream.listen((settings) {
      if (mounted) {
        setState(() {
          _currentSettings = settings;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Выбор региона
            _buildRegionSelector(),
            const SizedBox(height: 16),

            // Настройки валюты
            _buildCurrencySelector(),
            const SizedBox(height: 16),

            // Настройки формата даты
            _buildDateFormatSelector(),
            const SizedBox(height: 16),

            // Настройки формата времени
            _buildTimeFormatSelector(),
            const SizedBox(height: 16),

            // Настройки формата чисел
            _buildNumberFormatSelector(),
            const SizedBox(height: 16),

            // Часовой пояс
            _buildTimezoneSelector(),
            const SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector() {
    final supportedRegions = _regionalService.supportedRegions;

    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.regionCode,
      decoration: const InputDecoration(
        labelText: 'Region',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.public),
      ),
      items: supportedRegions.map((region) {
        return DropdownMenuItem<String>(
          value: region.code,
          child: Text('${region.name} (${region.code})'),
        );
      }).toList(),
      onChanged: (String? newRegion) async {
        if (newRegion != null) {
          try {
            await _regionalService.setRegion(newRegion);
            widget.onSettingsChanged?.call(_regionalService.currentSettings);
          } catch (e) {
            _showErrorSnackBar('Failed to change region: $e');
          }
        }
      },
    );
  }

  Widget _buildCurrencySelector() {
    final supportedRegions = _regionalService.supportedRegions;
    final currencies = supportedRegions.map((r) => r.currency).toSet().toList();

    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.currency,
      decoration: const InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      items: currencies.map((currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: (String? newCurrency) async {
        if (newCurrency != null) {
          final newSettings = _currentSettings.copyWith(currency: newCurrency);
          await _updateSettings(newSettings);
        }
      },
    );
  }

  Widget _buildDateFormatSelector() {
    final supportedRegions = _regionalService.supportedRegions;
    final dateFormats = supportedRegions.map((r) => r.dateFormat).toSet().toList();

    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.dateFormat,
      decoration: const InputDecoration(
        labelText: 'Date Format',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      items: dateFormats.map((format) {
        return DropdownMenuItem<String>(
          value: format,
          child: Text('$format (${_formatDateExample(format)})'),
        );
      }).toList(),
      onChanged: (String? newFormat) async {
        if (newFormat != null) {
          final newSettings = _currentSettings.copyWith(dateFormat: newFormat);
          await _updateSettings(newSettings);
        }
      },
    );
  }

  Widget _buildTimeFormatSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.timeFormat,
      decoration: const InputDecoration(
        labelText: 'Time Format',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time),
      ),
      items: const [
        DropdownMenuItem<String>(
          value: '12h',
          child: Text('12-hour (1:30 PM)'),
        ),
        DropdownMenuItem<String>(
          value: '24h',
          child: Text('24-hour (13:30)'),
        ),
      ],
      onChanged: (String? newFormat) async {
        if (newFormat != null) {
          final newSettings = _currentSettings.copyWith(timeFormat: newFormat);
          await _updateSettings(newSettings);
        }
      },
    );
  }

  Widget _buildNumberFormatSelector() {
    final supportedRegions = _regionalService.supportedRegions;
    final numberFormats = supportedRegions.map((r) => r.numberFormat).toSet().toList();

    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.numberFormat,
      decoration: const InputDecoration(
        labelText: 'Number Format',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.numbers),
      ),
      items: numberFormats.map((format) {
        return DropdownMenuItem<String>(
          value: format,
          child: Text('$format (${_formatNumberExample(format)})'),
        );
      }).toList(),
      onChanged: (String? newFormat) async {
        if (newFormat != null) {
          final newSettings = _currentSettings.copyWith(numberFormat: newFormat);
          await _updateSettings(newSettings);
        }
      },
    );
  }

  Widget _buildTimezoneSelector() {
    final supportedRegions = _regionalService.supportedRegions;
    final timezones = supportedRegions.map((r) => r.timezone).toSet().toList();

    return DropdownButtonFormField<String>(
      initialValue: _currentSettings.timezone,
      decoration: const InputDecoration(
        labelText: 'Timezone',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
      ),
      items: timezones.map((timezone) {
        return DropdownMenuItem<String>(
          value: timezone,
          child: Text(timezone),
        );
      }).toList(),
      onChanged: (String? newTimezone) async {
        if (newTimezone != null) {
          final newSettings = _currentSettings.copyWith(timezone: newTimezone);
          await _updateSettings(newSettings);
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _detectRegionalSettings,
            child: const Text('Auto-detect'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _resetToDefaults,
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  String _formatDateExample(String format) {
    final now = DateTime.now();
    return _regionalService.formatDate(now);
  }

  String _formatNumberExample(String format) {
    return _regionalService.formatNumber(1234.56);
  }

  Future<void> _updateSettings(RegionalSettings newSettings) async {
    try {
      // В реальном приложении здесь будет обновление через сервис
      setState(() {
        _currentSettings = newSettings;
      });
      widget.onSettingsChanged?.call(newSettings);
    } catch (e) {
      _showErrorSnackBar('Failed to update settings: $e');
    }
  }

  Future<void> _detectRegionalSettings() async {
    try {
      // В реальном приложении здесь будет определение региона по локали системы
      await _regionalService.detectRegionFromLocale('en_US');
      setState(() {
        _currentSettings = _regionalService.currentSettings;
      });
      widget.onSettingsChanged?.call(_currentSettings);
    } catch (e) {
      _showErrorSnackBar('Failed to detect regional settings: $e');
    }
  }

  void _resetToDefaults() {
    final defaultSettings = RegionalSettings.defaultSettings();
    setState(() {
      _currentSettings = defaultSettings;
    });
    widget.onSettingsChanged?.call(defaultSettings);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Виджет для отображения примеров форматирования
class FormattingExamplesWidget extends StatelessWidget {
  final RegionalSettings settings;

  const FormattingExamplesWidget({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final now = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formatting Examples',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildExampleRow(
              'Date',
              regionalService.formatDate(now),
              Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            _buildExampleRow(
              'Time',
              regionalService.formatTime(now),
              Icons.access_time,
            ),
            const SizedBox(height: 8),
            _buildExampleRow(
              'Number',
              regionalService.formatNumber(1234.56),
              Icons.numbers,
            ),
            const SizedBox(height: 8),
            _buildExampleRow(
              'Currency',
              regionalService.formatCurrency(1234.56),
              Icons.attach_money,
            ),
            const SizedBox(height: 8),
            _buildExampleRow(
              'Percentage',
              regionalService.formatPercentage(85.5),
              Icons.percent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
