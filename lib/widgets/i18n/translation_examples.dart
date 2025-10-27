import 'package:flutter/material.dart';

import '../../services/i18n/regional_settings_service.dart';
import 'currency_input_field.dart';
import 'date_time_picker.dart';
import 'language_selector.dart';
import 'number_format_widget.dart';
import 'regional_settings_widget.dart';
import 'translation_widget.dart';

/// Виджет с примерами использования интернационализации
class TranslationExamplesWidget extends StatefulWidget {
  const TranslationExamplesWidget({super.key});

  @override
  State<TranslationExamplesWidget> createState() => _TranslationExamplesWidgetState();
}

class _TranslationExamplesWidgetState extends State<TranslationExamplesWidget> {
  final RegionalSettingsService _regionalService = RegionalSettingsService();

  String _selectedCurrency = 'USD';

  double _sampleNumber = 1234.56;
  double _samplePercentage = 85.5;
  DateTime _sampleDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _regionalService.currentSettings.currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslationWidget('app_title'),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageSection(),
            const SizedBox(height: 24),
            _buildRegionalSettingsSection(),
            const SizedBox(height: 24),
            _buildTranslationExamplesSection(),
            const SizedBox(height: 24),
            _buildDateFormattingSection(),
            const SizedBox(height: 24),
            _buildNumberFormattingSection(),
            const SizedBox(height: 24),
            _buildCurrencyFormattingSection(),
            const SizedBox(height: 24),
            _buildInteractiveExamplesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Selection',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text('Current Language: '),
                TranslationWidget('language_selector.title'),
                Spacer(),
                LanguageSelector(),
              ],
            ),
            const SizedBox(height: 16),
            const TranslationWidget(
              'welcome_message',
              parameters: {'username': 'John Doe'},
            ),
            const SizedBox(height: 8),
            const TranslationWidget(
              'user_count',
              parameters: {'count': 42},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalSettingsSection() {
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
            const RegionalSettingsWidget(),
            const SizedBox(height: 16),
            const FormattingExamplesWidget(
              settings: RegionalSettings(
                regionCode: 'US',
                currency: 'USD',
                dateFormat: 'MM/dd/yyyy',
                timeFormat: '12h',
                numberFormat: '1,234.56',
                timezone: 'America/New_York',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationExamplesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translation Examples',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildTranslationExample('app_title', 'Application Title'),
            _buildTranslationExample('welcome_message', 'Welcome Message with Parameter'),
            _buildTranslationExample('button_ok', 'OK Button'),
            _buildTranslationExample('button_cancel', 'Cancel Button'),
            _buildTranslationExample('settings.language', 'Language Setting'),
            _buildTranslationExample('settings.theme', 'Theme Setting'),
            _buildTranslationExample('error_messages.network_error', 'Network Error'),
            _buildTranslationExample('dashboard.title', 'Dashboard Title'),
            _buildTranslationExample('profile.title', 'Profile Title'),
            _buildTranslationExample('trust_network.title', 'Trust Network Title'),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationExample(String key, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: TranslationWidget(key),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFormattingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time Formatting',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            RegionalDatePicker(
              initialDate: _sampleDate,
              onDateChanged: (date) {
                setState(() {
                  _sampleDate = date;
                });
              },
              label: 'Select Date',
            ),
            const SizedBox(height: 16),
            RegionalTimePicker(
              initialTime: TimeOfDay.fromDateTime(_sampleDate),
              onTimeChanged: (time) {
                setState(() {
                  _sampleDate = DateTime(
                    _sampleDate.year,
                    _sampleDate.month,
                    _sampleDate.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
              label: 'Select Time',
            ),
            const SizedBox(height: 16),
            RegionalDateTimePicker(
              initialDateTime: _sampleDate,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _sampleDate = dateTime;
                });
              },
              label: 'Date & Time',
            ),
            const SizedBox(height: 16),
            RelativeTimeWidget(
              dateTime: _sampleDate,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberFormattingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number Formatting',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            RegionalNumberInputField(
              initialValue: _sampleNumber,
              onChanged: (value) {
                setState(() {
                  _sampleNumber = value;
                });
              },
              label: 'Enter Number',
              helperText: 'Numbers will be formatted according to regional settings',
            ),
            const SizedBox(height: 16),
            NumberDisplayWidget(
              value: _sampleNumber,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            PercentageInputField(
              initialValue: _samplePercentage,
              onChanged: (value) {
                setState(() {
                  _samplePercentage = value;
                });
              },
              label: 'Enter Percentage',
            ),
            const SizedBox(height: 16),
            PercentageDisplayWidget(
              value: _samplePercentage,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            StatisticsWidget(
              title: 'Sample Statistics',
              items: [
                const StatisticItem(
                  label: 'Total Users',
                  value: 1234,
                  type: StatisticType.number,
                ),
                StatisticItem(
                  label: 'Revenue',
                  value: 56789.99,
                  type: StatisticType.currency,
                  currency: _selectedCurrency,
                ),
                const StatisticItem(
                  label: 'Growth Rate',
                  value: 15.5,
                  type: StatisticType.percentage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyFormattingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency Formatting',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CurrencySelector(
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: (currency) {
                setState(() {
                  _selectedCurrency = currency;
                });
              },
            ),
            const SizedBox(height: 16),
            CurrencyInputField(
              initialValue: _sampleNumber,
              onChanged: (value) {
                setState(() {
                  _sampleNumber = value;
                });
              },
              label: 'Enter Amount',
              currencyCode: _selectedCurrency,
            ),
            const SizedBox(height: 16),
            CurrencyDisplayWidget(
              value: _sampleNumber,
              currencyCode: _selectedCurrency,
              style: Theme.of(context).textTheme.bodyLarge,
              showSymbol: true,
              showCode: true,
            ),
            const SizedBox(height: 16),
            ExchangeRateWidget(
              fromCurrency: 'USD',
              toCurrency: _selectedCurrency,
              rate: 1.2, // Примерный курс
              lastUpdated: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveExamplesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Examples',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showTranslationDialog();
              },
              child: const TranslationWidget('button_ok'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showRegionalSettingsDialog();
              },
              child: const TranslationWidget('settings.regional_settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showDateFormattingDialog();
              },
              child: const Text('Date Formatting Examples'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslationWidget('settings.language'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TranslationWidget('language_selector.title'),
            SizedBox(height: 16),
            LanguageSelector(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslationWidget('button_ok'),
          ),
        ],
      ),
    );
  }

  void _showRegionalSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TranslationWidget('settings.regional_settings'),
        content: const SingleChildScrollView(
          child: RegionalSettingsWidget(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslationWidget('button_ok'),
          ),
        ],
      ),
    );
  }

  void _showDateFormattingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Formatting Examples'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RegionalDatePicker(
                initialDate: DateTime.now(),
                onDateChanged: (date) {},
                label: 'Sample Date Picker',
              ),
              const SizedBox(height: 16),
              RelativeTimeWidget(
                dateTime: DateTime.now().subtract(const Duration(hours: 2)),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslationWidget('button_ok'),
          ),
        ],
      ),
    );
  }
}
