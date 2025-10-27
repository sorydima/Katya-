# Руководство по интернационализации (i18n) Katya

## Обзор

Система интернационализации Katya предоставляет полную поддержку множественных языков, региональных настроек и локализации пользовательского интерфейса. Система включает в себя:

- **Управление переводами**: Загрузка и управление переводами из JSON файлов
- **Региональные настройки**: Форматирование дат, чисел, валют по регионам
- **UI компоненты**: Готовые виджеты для локализации
- **Поддержка параметров**: Динамические переводы с подстановкой значений
- **Плюрализация**: Правильное отображение множественных форм

## Архитектура

### Основные сервисы

#### 1. InternationalizationService

Центральный сервис для управления языками и переводами:

```dart
final i18nService = InternationalizationService();

// Инициализация
await i18nService.initialize(initialLocale: Locale('ru'));

// Получение перевода
String message = i18nService.translate('welcome_message',
    parameters: {'username': 'John'});

// Смена языка
await i18nService.changeLanguage('en');
```

#### 2. TranslationManager

Расширенный менеджер переводов с поддержкой плюрализации:

```dart
final translationManager = TranslationManager();

// Перевод с плюрализацией
String countMessage = translationManager.getTranslation('user_count',
    parameters: {'count': 5});
```

#### 3. RegionalSettingsService

Управление региональными настройками:

```dart
final regionalService = RegionalSettingsService();

// Форматирование даты
String formattedDate = regionalService.formatDate(DateTime.now());

// Форматирование валюты
String formattedCurrency = regionalService.formatCurrency(1234.56,
    currencyCode: 'EUR');

// Форматирование чисел
String formattedNumber = regionalService.formatNumber(1234.56);
```

## Структура файлов

```
assets/translations/
├── en.json          # Английские переводы
├── ru.json          # Русские переводы
├── de.json          # Немецкие переводы (пример)
└── fr.json          # Французские переводы (пример)

lib/services/i18n/
├── internationalization_service.dart    # Основной сервис i18n
├── translation_manager.dart             # Менеджер переводов
└── regional_settings_service.dart       # Региональные настройки

lib/widgets/i18n/
├── translation_widget.dart              # Виджет для переводов
├── language_selector.dart               # Выбор языка
├── regional_settings_widget.dart        # Настройки региона
├── date_time_picker.dart                # Выбор даты/времени
├── currency_input_field.dart            # Ввод валюты
├── number_format_widget.dart            # Форматирование чисел
└── translation_examples.dart            # Примеры использования
```

## Формат файлов переводов

### Основная структура (en.json)

```json
{
  "app_title": "Katya Trust Network",
  "welcome_message": "Welcome to Katya, {{username}}!",
  "greeting": {
    "morning": "Good morning!",
    "afternoon": "Good afternoon!",
    "evening": "Good evening!"
  },
  "button_ok": "OK",
  "button_cancel": "Cancel",
  "user_count": {
    "zero": "No users online.",
    "one": "One user online.",
    "two": "Two users online.",
    "few": "{{count}} users online.",
    "many": "{{count}} users online.",
    "other": "{{count}} users online."
  },
  "message_count": {
    "one": "You have one new message.",
    "other": "You have {{count}} new messages."
  },
  "gender_specific_message": {
    "male": "He is a developer.",
    "female": "She is a developer.",
    "other": "They are developers."
  },
  "settings": {
    "language": "Language",
    "regional_settings": "Regional Settings",
    "theme": "Theme"
  }
}
```

### Русские переводы (ru.json)

```json
{
  "app_title": "Сеть Доверия Katya",
  "welcome_message": "Добро пожаловать в Katya, {{username}}!",
  "greeting": {
    "morning": "Доброе утро!",
    "afternoon": "Добрый день!",
    "evening": "Добрый вечер!"
  },
  "button_ok": "ОК",
  "button_cancel": "Отмена",
  "user_count": {
    "zero": "Пользователей онлайн нет.",
    "one": "Один пользователь онлайн.",
    "two": "Два пользователя онлайн.",
    "few": "{{count}} пользователя онлайн.",
    "many": "{{count}} пользователей онлайн.",
    "other": "{{count}} пользователей онлайн."
  },
  "message_count": {
    "one": "У вас одно новое сообщение.",
    "few": "У вас {{count}} новых сообщения.",
    "many": "У вас {{count}} новых сообщений.",
    "other": "У вас {{count}} новых сообщений."
  },
  "gender_specific_message": {
    "male": "Он разработчик.",
    "female": "Она разработчик.",
    "other": "Они разработчики."
  },
  "settings": {
    "language": "Язык",
    "regional_settings": "Региональные настройки",
    "theme": "Тема"
  }
}
```

## Использование UI компонентов

### 1. TranslationWidget

Базовый виджет для отображения переводов:

```dart
// Простой перевод
TranslationWidget('app_title')

// Перевод с параметрами
TranslationWidget(
  'welcome_message',
  parameters: {'username': 'John'},
)

// Перевод с плюрализацией
TranslationWidget(
  'user_count',
  parameters: {'count': 5},
)
```

### 2. LanguageSelector

Виджет для выбора языка:

```dart
LanguageSelector()
```

### 3. RegionalSettingsWidget

Настройки региона:

```dart
RegionalSettingsWidget(
  onSettingsChanged: (settings) {
    print('Region changed: ${settings.regionCode}');
  },
)
```

### 4. Дата и время

```dart
// Выбор даты
RegionalDatePicker(
  initialDate: DateTime.now(),
  onDateChanged: (date) {
    print('Selected date: $date');
  },
  label: 'Select Date',
)

// Выбор времени
RegionalTimePicker(
  initialTime: TimeOfDay.now(),
  onTimeChanged: (time) {
    print('Selected time: $time');
  },
  label: 'Select Time',
)

// Относительное время
RelativeTimeWidget(
  dateTime: DateTime.now().subtract(Duration(hours: 2)),
  style: TextStyle(fontSize: 16),
)
```

### 5. Валютные поля

```dart
// Ввод валюты
CurrencyInputField(
  initialValue: 100.0,
  onChanged: (value) {
    print('Amount: $value');
  },
  label: 'Enter Amount',
  currencyCode: 'USD',
)

// Отображение валюты
CurrencyDisplayWidget(
  value: 1234.56,
  currencyCode: 'EUR',
  showSymbol: true,
  showCode: true,
)

// Выбор валюты
CurrencySelector(
  selectedCurrency: 'USD',
  onCurrencyChanged: (currency) {
    print('Currency changed: $currency');
  },
)
```

### 6. Числовые поля

```dart
// Ввод чисел
RegionalNumberInputField(
  initialValue: 1234.56,
  onChanged: (value) {
    print('Number: $value');
  },
  label: 'Enter Number',
  allowDecimals: true,
)

// Отображение чисел
NumberDisplayWidget(
  value: 1234.56,
  style: TextStyle(fontSize: 16),
)

// Ввод процентов
PercentageInputField(
  initialValue: 85.5,
  onChanged: (value) {
    print('Percentage: $value%');
  },
  label: 'Enter Percentage',
)

// Статистика
StatisticsWidget(
  title: 'System Statistics',
  items: [
    StatisticItem(
      label: 'Total Users',
      value: 1234,
      type: StatisticType.number,
    ),
    StatisticItem(
      label: 'Revenue',
      value: 56789.99,
      type: StatisticType.currency,
      currency: 'USD',
    ),
    StatisticItem(
      label: 'Growth Rate',
      value: 15.5,
      type: StatisticType.percentage,
    ),
  ],
)
```

## Поддерживаемые регионы

Система поддерживает следующие регионы:

### Северная Америка

- **US**: США (USD, MM/dd/yyyy, 12h, 1,234.56)
- **CA**: Канада (CAD, yyyy-MM-dd, 24h, 1,234.56)

### Европа

- **DE**: Германия (EUR, dd.MM.yyyy, 24h, 1.234,56)
- **FR**: Франция (EUR, dd/MM/yyyy, 24h, 1 234,56)
- **GB**: Великобритания (GBP, dd/MM/yyyy, 12h, 1,234.56)
- **IT**: Италия (EUR, dd/MM/yyyy, 24h, 1.234,56)
- **ES**: Испания (EUR, dd/MM/yyyy, 24h, 1.234,56)

### Азия

- **JP**: Япония (JPY, yyyy/MM/dd, 24h, 1,234)
- **CN**: Китай (CNY, yyyy-MM-dd, 24h, 1,234.56)
- **KR**: Южная Корея (KRW, yyyy.MM.dd, 24h, 1,234)
- **IN**: Индия (INR, dd-MM-yyyy, 12h, 1,23,456.78)

### Россия и СНГ

- **RU**: Россия (RUB, dd.MM.yyyy, 24h, 1 234,56)

## Добавление новых языков

### 1. Создание файла переводов

Создайте новый файл в `assets/translations/`:

```json
// assets/translations/de.json
{
  "app_title": "Katya Vertrauensnetzwerk",
  "welcome_message": "Willkommen bei Katya, {{username}}!",
  "button_ok": "OK",
  "button_cancel": "Abbrechen"
}
```

### 2. Обновление LanguageSelector

Добавьте новый язык в виджет выбора:

```dart
DropdownMenuItem(
  value: Locale('de'),
  child: Text('Deutsch'),
),
```

### 3. Обновление RegionalSettingsService

Добавьте поддержку нового региона:

```dart
static const RegionInfo _germany = RegionInfo(
  code: 'DE',
  name: 'Germany',
  currency: 'EUR',
  dateFormat: 'dd.MM.yyyy',
  timeFormat: '24h',
  numberFormat: '1.234,56',
  timezone: 'Europe/Berlin',
);
```

## Лучшие практики

### 1. Организация ключей переводов

Используйте иерархическую структуру:

```json
{
  "navigation": {
    "home": "Home",
    "profile": "Profile",
    "settings": "Settings"
  },
  "forms": {
    "validation": {
      "required": "This field is required",
      "email": "Please enter a valid email"
    }
  }
}
```

### 2. Параметры в переводах

Всегда используйте именованные параметры:

```json
{
  "welcome_user": "Welcome, {{username}}!",
  "items_count": "You have {{count}} items",
  "date_range": "From {{startDate}} to {{endDate}}"
}
```

### 3. Плюрализация

Поддерживайте все формы множественного числа:

```json
{
  "file_count": {
    "zero": "No files",
    "one": "One file",
    "two": "Two files",
    "few": "{{count}} files",
    "many": "{{count}} files",
    "other": "{{count}} files"
  }
}
```

### 4. Контекстные переводы

Используйте контекст для различения значений:

```json
{
  "time": {
    "morning": "Good morning",
    "afternoon": "Good afternoon",
    "evening": "Good evening"
  },
  "period": {
    "morning": "AM",
    "afternoon": "PM"
  }
}
```

## Отладка и тестирование

### 1. Проверка отсутствующих переводов

Система автоматически логирует отсутствующие ключи:

```dart
// В консоли появится:
// Translation key not found: missing_key for locale en
```

### 2. Тестирование разных локалей

```dart
// В тестах
await i18nService.changeLanguage('ru');
String message = i18nService.translate('welcome_message');
// Проверяем, что сообщение на русском языке
```

### 3. Проверка форматирования

```dart
// Тестирование региональных настроек
regionalService.setRegion('DE');
String formattedDate = regionalService.formatDate(DateTime(2023, 12, 25));
// Ожидаемый результат: "25.12.2023"
```

## Производительность

### 1. Ленивая загрузка

Переводы загружаются только при необходимости:

```dart
// Переводы загружаются при первом обращении
String message = i18nService.translate('welcome_message');
```

### 2. Кэширование

Переводы кэшируются в памяти для быстрого доступа.

### 3. Оптимизация виджетов

Используйте `const` конструкторы где возможно:

```dart
const TranslationWidget('app_title')
```

## Расширение функциональности

### 1. Добавление новых типов форматирования

```dart
// В RegionalSettingsService
String formatPhoneNumber(String number) {
  // Логика форматирования телефонных номеров
}

String formatAddress(Map<String, String> address) {
  // Логика форматирования адресов
}
```

### 2. Поддержка RTL языков

```dart
// В TranslationWidget
TextDirection getTextDirection() {
  switch (currentLanguage) {
    case 'ar':
    case 'he':
    case 'fa':
      return TextDirection.rtl;
    default:
      return TextDirection.ltr;
  }
}
```

### 3. Интеграция с внешними API

```dart
// Автоматический перевод через Google Translate API
class AutoTranslationService {
  Future<String> translateText(String text, String targetLanguage) {
    // Интеграция с Google Translate
  }
}
```

## Заключение

Система интернационализации Katya предоставляет комплексное решение для поддержки множественных языков и региональных настроек. Она легко расширяется, хорошо документирована и готова для использования в продакшене.

Основные преимущества:

- ✅ Полная поддержка i18n/l10n
- ✅ Региональные настройки
- ✅ Готовые UI компоненты
- ✅ Поддержка параметров и плюрализации
- ✅ Простота расширения
- ✅ Высокая производительность
- ✅ Подробная документация
