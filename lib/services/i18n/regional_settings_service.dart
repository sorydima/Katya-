import 'dart:async';

import 'package:equatable/equatable.dart';

/// Сервис для управления региональными настройками
class RegionalSettingsService {
  static final RegionalSettingsService _instance = RegionalSettingsService._internal();

  // Текущие региональные настройки
  RegionalSettings _currentSettings = RegionalSettings.defaultSettings();

  // Поддерживаемые регионы
  final List<SupportedRegion> _supportedRegions = [
    const SupportedRegion(
      code: 'US',
      name: 'United States',
      currency: 'USD',
      dateFormat: 'MM/dd/yyyy',
      timeFormat: '12h',
      numberFormat: '1,234.56',
      timezone: 'America/New_York',
    ),
    const SupportedRegion(
      code: 'RU',
      name: 'Russia',
      currency: 'RUB',
      dateFormat: 'dd.MM.yyyy',
      timeFormat: '24h',
      numberFormat: '1 234,56',
      timezone: 'Europe/Moscow',
    ),
    const SupportedRegion(
      code: 'GB',
      name: 'United Kingdom',
      currency: 'GBP',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
      numberFormat: '1,234.56',
      timezone: 'Europe/London',
    ),
    const SupportedRegion(
      code: 'DE',
      name: 'Germany',
      currency: 'EUR',
      dateFormat: 'dd.MM.yyyy',
      timeFormat: '24h',
      numberFormat: '1.234,56',
      timezone: 'Europe/Berlin',
    ),
    const SupportedRegion(
      code: 'FR',
      name: 'France',
      currency: 'EUR',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
      numberFormat: '1 234,56',
      timezone: 'Europe/Paris',
    ),
    const SupportedRegion(
      code: 'JP',
      name: 'Japan',
      currency: 'JPY',
      dateFormat: 'yyyy/MM/dd',
      timeFormat: '24h',
      numberFormat: '1,234',
      timezone: 'Asia/Tokyo',
    ),
    const SupportedRegion(
      code: 'CN',
      name: 'China',
      currency: 'CNY',
      dateFormat: 'yyyy-MM-dd',
      timeFormat: '24h',
      numberFormat: '1,234.56',
      timezone: 'Asia/Shanghai',
    ),
    const SupportedRegion(
      code: 'IN',
      name: 'India',
      currency: 'INR',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '12h',
      numberFormat: '1,23,456.78',
      timezone: 'Asia/Kolkata',
    ),
    const SupportedRegion(
      code: 'BR',
      name: 'Brazil',
      currency: 'BRL',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
      numberFormat: '1.234,56',
      timezone: 'America/Sao_Paulo',
    ),
    const SupportedRegion(
      code: 'AU',
      name: 'Australia',
      currency: 'AUD',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
      numberFormat: '1,234.56',
      timezone: 'Australia/Sydney',
    ),
  ];

  // Поток для уведомлений об изменении настроек
  final StreamController<RegionalSettings> _settingsChangeController = StreamController.broadcast();
  Stream<RegionalSettings> get settingsChangeStream => _settingsChangeController.stream;

  factory RegionalSettingsService() => _instance;
  RegionalSettingsService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadUserSettings();
    print('RegionalSettingsService initialized with region: ${_currentSettings.regionCode}');
  }

  /// Получение текущих настроек
  RegionalSettings get currentSettings => _currentSettings;

  /// Получение всех поддерживаемых регионов
  List<SupportedRegion> get supportedRegions => List.unmodifiable(_supportedRegions);

  /// Установка региона
  Future<void> setRegion(String regionCode) async {
    final region = _supportedRegions.firstWhere(
      (r) => r.code == regionCode,
      orElse: () => throw ArgumentError('Region $regionCode is not supported'),
    );

    final newSettings = _currentSettings.copyWith(
      regionCode: regionCode,
      currency: region.currency,
      dateFormat: region.dateFormat,
      timeFormat: region.timeFormat,
      numberFormat: region.numberFormat,
      timezone: region.timezone,
    );

    await _updateSettings(newSettings);
  }

  /// Форматирование даты
  String formatDate(DateTime date) {
    return _formatDateWithPattern(date, _currentSettings.dateFormat);
  }

  /// Форматирование времени
  String formatTime(DateTime time) {
    return _formatTimeWithPattern(time, _currentSettings.timeFormat);
  }

  /// Форматирование даты и времени
  String formatDateTime(DateTime dateTime) {
    final dateStr = formatDate(dateTime);
    final timeStr = formatTime(dateTime);
    return '$dateStr $timeStr';
  }

  /// Форматирование числа
  String formatNumber(double number, {int? decimalPlaces}) {
    return _formatNumberWithPattern(number, _currentSettings.numberFormat, decimalPlaces);
  }

  /// Форматирование валюты
  String formatCurrency(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? _currentSettings.currency;
    final formattedNumber = formatNumber(amount, decimalPlaces: 2);
    return '$formattedNumber $currency';
  }

  /// Форматирование процентов
  String formatPercentage(double percentage, {int decimalPlaces = 1}) {
    final formattedNumber = formatNumber(percentage, decimalPlaces: decimalPlaces);
    return '$formattedNumber%';
  }

  /// Парсинг даты
  DateTime? parseDate(String dateString) {
    try {
      return _parseDateWithPattern(dateString, _currentSettings.dateFormat);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  /// Парсинг числа
  double? parseNumber(String numberString) {
    try {
      return _parseNumberWithPattern(numberString, _currentSettings.numberFormat);
    } catch (e) {
      print('Error parsing number: $e');
      return null;
    }
  }

  /// Получение региона по коду
  SupportedRegion? getRegionByCode(String code) {
    try {
      return _supportedRegions.firstWhere((r) => r.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Определение региона по локали
  Future<void> detectRegionFromLocale(String locale) async {
    // Простое сопоставление локали с регионом
    final regionMap = {
      'en_US': 'US',
      'ru_RU': 'RU',
      'en_GB': 'GB',
      'de_DE': 'DE',
      'fr_FR': 'FR',
      'ja_JP': 'JP',
      'zh_CN': 'CN',
      'hi_IN': 'IN',
      'pt_BR': 'BR',
      'en_AU': 'AU',
    };

    final regionCode = regionMap[locale] ?? 'US';
    await setRegion(regionCode);
  }

  /// Обновление настроек
  Future<void> _updateSettings(RegionalSettings newSettings) async {
    _currentSettings = newSettings;
    await _saveUserSettings();
    _settingsChangeController.add(newSettings);
    print('Regional settings updated: ${newSettings.regionCode}');
  }

  /// Сохранение настроек пользователя
  Future<void> _saveUserSettings() async {
    try {
      // В реальном приложении здесь будет сохранение в файл или базу данных
      final settingsJson = _currentSettings.toJson();
      print('Saved regional settings: $settingsJson');
    } catch (e) {
      print('Failed to save regional settings: $e');
    }
  }

  /// Загрузка настроек пользователя
  Future<void> _loadUserSettings() async {
    try {
      // В реальном приложении здесь будет загрузка из файла или базы данных
      // Пока используем настройки по умолчанию
      _currentSettings = RegionalSettings.defaultSettings();
    } catch (e) {
      print('Failed to load regional settings: $e');
      _currentSettings = RegionalSettings.defaultSettings();
    }
  }

  /// Форматирование даты по паттерну
  String _formatDateWithPattern(DateTime date, String pattern) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    switch (pattern) {
      case 'MM/dd/yyyy':
        return '$month/$day/$year';
      case 'dd.MM.yyyy':
        return '$day.$month.$year';
      case 'dd/MM/yyyy':
        return '$day/$month/$year';
      case 'yyyy/MM/dd':
        return '$year/$month/$day';
      case 'yyyy-MM-dd':
        return '$year-$month-$day';
      default:
        return '$day/$month/$year';
    }
  }

  /// Форматирование времени по паттерну
  String _formatTimeWithPattern(DateTime time, String pattern) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');

    if (pattern == '12h') {
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      return '$hour12:$minute $period';
    } else {
      return '${hour.toString().padLeft(2, '0')}:$minute:$second';
    }
  }

  /// Форматирование числа по паттерну
  String _formatNumberWithPattern(double number, String pattern, int? decimalPlaces) {
    final places = decimalPlaces ?? 2;
    final rounded = number.toStringAsFixed(places);
    final parts = rounded.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    String formattedInteger;
    switch (pattern) {
      case '1,234.56':
        formattedInteger = _addThousandsSeparator(integerPart, ',');
        return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
      case '1 234,56':
        formattedInteger = _addThousandsSeparator(integerPart, ' ');
        return decimalPart.isNotEmpty ? '$formattedInteger,$decimalPart' : formattedInteger;
      case '1.234,56':
        formattedInteger = _addThousandsSeparator(integerPart, '.');
        return decimalPart.isNotEmpty ? '$formattedInteger,$decimalPart' : formattedInteger;
      case '1,23,456.78': // Indian format
        formattedInteger = _addIndianThousandsSeparator(integerPart);
        return decimalPart.isNotEmpty ? '$formattedInteger.$decimalPart' : formattedInteger;
      case '1,234': // Japanese format (no decimals)
        return _addThousandsSeparator(integerPart, ',');
      default:
        return rounded;
    }
  }

  /// Добавление разделителей тысяч
  String _addThousandsSeparator(String number, String separator) {
    final reversed = number.split('').reversed.join();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final chunk = reversed.substring(i, (i + 3).clamp(0, reversed.length));
      chunks.add(chunk);
    }

    return chunks.join(separator).split('').reversed.join('');
  }

  /// Добавление разделителей тысяч в индийском формате
  String _addIndianThousandsSeparator(String number) {
    final reversed = number.split('').reversed.join();
    final chunks = <String>[];

    // Первые три цифры
    if (reversed.length >= 3) {
      chunks.add(reversed.substring(0, 3));
    } else {
      chunks.add(reversed);
      return chunks.join('').split('').reversed.join('');
    }

    // Остальные цифры группами по две
    for (int i = 3; i < reversed.length; i += 2) {
      final chunk = reversed.substring(i, (i + 2).clamp(0, reversed.length));
      chunks.add(chunk);
    }

    return chunks.join(',').split('').reversed.join('');
  }

  /// Парсинг даты по паттерну
  DateTime _parseDateWithPattern(String dateString, String pattern) {
    final parts = dateString.split(RegExp(r'[/.\-]'));
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $dateString');
    }

    int year;
    int month;
    int day;

    switch (pattern) {
      case 'MM/dd/yyyy':
        month = int.parse(parts[0]);
        day = int.parse(parts[1]);
        year = int.parse(parts[2]);
      case 'dd.MM.yyyy':
      case 'dd/MM/yyyy':
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        year = int.parse(parts[2]);
      case 'yyyy/MM/dd':
      case 'yyyy-MM-dd':
        year = int.parse(parts[0]);
        month = int.parse(parts[1]);
        day = int.parse(parts[2]);
      default:
        throw FormatException('Unsupported date pattern: $pattern');
    }

    return DateTime(year, month, day);
  }

  /// Парсинг числа по паттерну
  double _parseNumberWithPattern(String numberString, String pattern) {
    String cleaned = numberString;

    switch (pattern) {
      case '1,234.56':
        cleaned = cleaned.replaceAll(',', '');
      case '1 234,56':
        cleaned = cleaned.replaceAll(' ', '').replaceAll(',', '.');
      case '1.234,56':
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      case '1,23,456.78':
        cleaned = cleaned.replaceAll(',', '');
      case '1,234':
        cleaned = cleaned.replaceAll(',', '');
    }

    return double.parse(cleaned);
  }

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _settingsChangeController.close();
  }
}

/// Региональные настройки
class RegionalSettings extends Equatable {
  final String regionCode;
  final String currency;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final String timezone;

  const RegionalSettings({
    required this.regionCode,
    required this.currency,
    required this.dateFormat,
    required this.timeFormat,
    required this.numberFormat,
    required this.timezone,
  });

  factory RegionalSettings.defaultSettings() {
    return const RegionalSettings(
      regionCode: 'US',
      currency: 'USD',
      dateFormat: 'MM/dd/yyyy',
      timeFormat: '12h',
      numberFormat: '1,234.56',
      timezone: 'America/New_York',
    );
  }

  RegionalSettings copyWith({
    String? regionCode,
    String? currency,
    String? dateFormat,
    String? timeFormat,
    String? numberFormat,
    String? timezone,
  }) {
    return RegionalSettings(
      regionCode: regionCode ?? this.regionCode,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionCode': regionCode,
      'currency': currency,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'numberFormat': numberFormat,
      'timezone': timezone,
    };
  }

  factory RegionalSettings.fromJson(Map<String, dynamic> json) {
    return RegionalSettings(
      regionCode: json['regionCode'] as String,
      currency: json['currency'] as String,
      dateFormat: json['dateFormat'] as String,
      timeFormat: json['timeFormat'] as String,
      numberFormat: json['numberFormat'] as String,
      timezone: json['timezone'] as String,
    );
  }

  @override
  List<Object?> get props => [regionCode, currency, dateFormat, timeFormat, numberFormat, timezone];
}

/// Поддерживаемый регион
class SupportedRegion extends Equatable {
  final String code;
  final String name;
  final String currency;
  final String dateFormat;
  final String timeFormat;
  final String numberFormat;
  final String timezone;

  const SupportedRegion({
    required this.code,
    required this.name,
    required this.currency,
    required this.dateFormat,
    required this.timeFormat,
    required this.numberFormat,
    required this.timezone,
  });

  @override
  List<Object?> get props => [code, name, currency, dateFormat, timeFormat, numberFormat, timezone];
}
