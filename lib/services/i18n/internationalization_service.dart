import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

/// Сервис интернационализации для поддержки множественных языков
class InternationalizationService {
  static final InternationalizationService _instance = InternationalizationService._internal();

  // Кэш переводов
  final Map<String, Map<String, String>> _translations = {};

  // Текущий язык
  String _currentLanguage = 'en';

  // Поддерживаемые языки
  final List<SupportedLanguage> _supportedLanguages = [
    const SupportedLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    const SupportedLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    const SupportedLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    const SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    const SupportedLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    const SupportedLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    const SupportedLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    const SupportedLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    const SupportedLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    const SupportedLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    const SupportedLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    const SupportedLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
  ];

  // Поток для уведомлений об изменении языка
  final StreamController<String> _languageChangeController = StreamController.broadcast();
  Stream<String> get languageChangeStream => _languageChangeController.stream;

  // Поток для уведомлений об ошибках перевода
  final StreamController<TranslationError> _translationErrorController = StreamController.broadcast();
  Stream<TranslationError> get translationErrorStream => _translationErrorController.stream;

  factory InternationalizationService() => _instance;
  InternationalizationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadTranslations();
    await _loadUserLanguagePreference();
    print('InternationalizationService initialized with language: $_currentLanguage');
  }

  /// Получение перевода по ключу
  String translate(String key, {Map<String, dynamic>? parameters}) {
    final translation = _getTranslation(key);
    if (translation == null) {
      _reportMissingTranslation(key);
      return key; // Возвращаем ключ как fallback
    }

    if (parameters != null && parameters.isNotEmpty) {
      return _interpolateParameters(translation, parameters);
    }

    return translation;
  }

  /// Получение перевода с плюрализацией
  String translatePlural(
    String key,
    int count, {
    Map<String, dynamic>? parameters,
  }) {
    final pluralKey = _getPluralKey(key, count);
    final translation = _getTranslation(pluralKey);

    if (translation == null) {
      _reportMissingTranslation(pluralKey);
      return key;
    }

    final params = {...?parameters, 'count': count};
    return _interpolateParameters(translation, params);
  }

  /// Установка текущего языка
  Future<void> setLanguage(String languageCode) async {
    if (!_isLanguageSupported(languageCode)) {
      throw ArgumentError('Language $languageCode is not supported');
    }

    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _saveUserLanguagePreference();
      _languageChangeController.add(languageCode);
      print('Language changed to: $languageCode');
    }
  }

  /// Получение текущего языка
  String get currentLanguage => _currentLanguage;

  /// Получение всех поддерживаемых языков
  List<SupportedLanguage> get supportedLanguages => List.unmodifiable(_supportedLanguages);

  /// Получение языка по коду
  SupportedLanguage? getLanguageByCode(String code) {
    try {
      return _supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Определение языка по локали системы
  Future<void> detectSystemLanguage() async {
    final systemLocale = Platform.localeName;
    final languageCode = systemLocale.split('_').first.toLowerCase();

    if (_isLanguageSupported(languageCode)) {
      await setLanguage(languageCode);
    } else {
      // Fallback на английский
      await setLanguage('en');
    }
  }

  /// Загрузка переводов для конкретного языка
  Future<void> loadLanguageTranslations(String languageCode) async {
    if (!_isLanguageSupported(languageCode)) {
      throw ArgumentError('Language $languageCode is not supported');
    }

    try {
      final translations = await _loadTranslationsForLanguage(languageCode);
      _translations[languageCode] = translations;
      print('Loaded translations for language: $languageCode');
    } catch (e) {
      _translationErrorController.add(TranslationError(
        languageCode: languageCode,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Предзагрузка переводов для всех языков
  Future<void> preloadAllTranslations() async {
    final futures = _supportedLanguages.map((lang) => loadLanguageTranslations(lang.code));
    await Future.wait(futures);
    print('Preloaded translations for all supported languages');
  }

  /// Проверка наличия перевода
  bool hasTranslation(String key, {String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    return _getTranslation(key, languageCode: lang) != null;
  }

  /// Получение всех ключей для текущего языка
  List<String> getAllTranslationKeys({String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    final translations = _translations[lang];
    return translations?.keys.toList() ?? [];
  }

  /// Добавление пользовательского перевода
  void addCustomTranslation(String key, String translation, {String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    _translations.putIfAbsent(lang, () => {});
    _translations[lang]![key] = translation;
  }

  /// Очистка пользовательских переводов
  void clearCustomTranslations({String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    _translations[lang]?.clear();
  }

  /// Экспорт переводов в JSON
  Map<String, dynamic> exportTranslations({String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    return _translations[lang] ?? {};
  }

  /// Импорт переводов из JSON
  Future<void> importTranslations(Map<String, dynamic> translations, {String? languageCode}) async {
    final lang = languageCode ?? _currentLanguage;
    _translations.putIfAbsent(lang, () => {});

    translations.forEach((key, value) {
      if (value is String) {
        _translations[lang]![key] = value;
      }
    });
  }

  /// Получение статистики переводов
  TranslationStats getTranslationStats({String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    final translations = _translations[lang] ?? {};

    int totalKeys = 0;
    int translatedKeys = 0;
    int missingKeys = 0;

    // Подсчитываем общее количество ключей (берем английский как базовый)
    final baseTranslations = _translations['en'] ?? {};
    totalKeys = baseTranslations.length;

    // Подсчитываем переведенные ключи
    for (final key in baseTranslations.keys) {
      if (translations.containsKey(key) && translations[key]!.isNotEmpty) {
        translatedKeys++;
      } else {
        missingKeys++;
      }
    }

    final percentage = totalKeys > 0 ? (translatedKeys / totalKeys * 100).round() : 0;

    return TranslationStats(
      languageCode: lang,
      totalKeys: totalKeys,
      translatedKeys: translatedKeys,
      missingKeys: missingKeys,
      completionPercentage: percentage,
      lastUpdated: DateTime.now(),
    );
  }

  /// Загрузка переводов из файлов
  Future<void> _loadTranslations() async {
    for (final language in _supportedLanguages) {
      try {
        final translations = await _loadTranslationsForLanguage(language.code);
        _translations[language.code] = translations;
      } catch (e) {
        print('Failed to load translations for ${language.code}: $e');
        _translationErrorController.add(TranslationError(
          languageCode: language.code,
          error: e.toString(),
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  /// Загрузка переводов для конкретного языка
  Future<Map<String, String>> _loadTranslationsForLanguage(String languageCode) async {
    try {
      final file = File('assets/translations/$languageCode.json');
      final content = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(content);

      final translations = <String, String>{};
      jsonData.forEach((key, value) {
        if (value is String) {
          translations[key] = value;
        }
      });

      return translations;
    } catch (e) {
      // Если файл не найден, возвращаем пустую карту
      print('Translation file not found for $languageCode: $e');
      return {};
    }
  }

  /// Получение перевода по ключу
  String? _getTranslation(String key, {String? languageCode}) {
    final lang = languageCode ?? _currentLanguage;
    return _translations[lang]?[key];
  }

  /// Получение ключа для плюрализации
  String _getPluralKey(String key, int count) {
    // Простая логика плюрализации (можно расширить)
    if (count == 0) {
      return '${key}_zero';
    } else if (count == 1) {
      return '${key}_one';
    } else if (count < 5) {
      return '${key}_few';
    } else {
      return '${key}_many';
    }
  }

  /// Интерполяция параметров в строке
  String _interpolateParameters(String text, Map<String, dynamic> parameters) {
    String result = text;
    parameters.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  /// Проверка поддержки языка
  bool _isLanguageSupported(String languageCode) {
    return _supportedLanguages.any((lang) => lang.code == languageCode);
  }

  /// Сохранение предпочтений пользователя
  Future<void> _saveUserLanguagePreference() async {
    try {
      final file = File('.user_preferences.json');
      final preferences = {
        'language': _currentLanguage,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(preferences));
    } catch (e) {
      print('Failed to save language preference: $e');
    }
  }

  /// Загрузка предпочтений пользователя
  Future<void> _loadUserLanguagePreference() async {
    try {
      final file = File('.user_preferences.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final preferences = jsonDecode(content) as Map<String, dynamic>;
        final savedLanguage = preferences['language'] as String?;

        if (savedLanguage != null && _isLanguageSupported(savedLanguage)) {
          _currentLanguage = savedLanguage;
        }
      }
    } catch (e) {
      print('Failed to load language preference: $e');
    }
  }

  /// Сообщение об отсутствующем переводе
  void _reportMissingTranslation(String key) {
    _translationErrorController.add(TranslationError(
      languageCode: _currentLanguage,
      error: 'Missing translation for key: $key',
      timestamp: DateTime.now(),
    ));
  }

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _languageChangeController.close();
    await _translationErrorController.close();
    _translations.clear();
  }
}

/// Поддерживаемый язык
class SupportedLanguage extends Equatable {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  List<Object?> get props => [code, name, nativeName, flag];
}

/// Статистика переводов
class TranslationStats extends Equatable {
  final String languageCode;
  final int totalKeys;
  final int translatedKeys;
  final int missingKeys;
  final int completionPercentage;
  final DateTime lastUpdated;

  const TranslationStats({
    required this.languageCode,
    required this.totalKeys,
    required this.translatedKeys,
    required this.missingKeys,
    required this.completionPercentage,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        languageCode,
        totalKeys,
        translatedKeys,
        missingKeys,
        completionPercentage,
        lastUpdated,
      ];
}

/// Ошибка перевода
class TranslationError extends Equatable {
  final String languageCode;
  final String error;
  final DateTime timestamp;

  const TranslationError({
    required this.languageCode,
    required this.error,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [languageCode, error, timestamp];
}
