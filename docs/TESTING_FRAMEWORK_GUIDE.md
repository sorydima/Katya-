# Руководство по тестированию системы Katya

## Обзор

Система Katya включает в себя комплексный фреймворк для тестирования, который обеспечивает надежность, качество и производительность всех компонентов системы.

## Компоненты системы тестирования

### 1. Основной фреймворк тестирования

**Файл:** `lib/testing/test_framework.dart`

Центральный компонент системы тестирования, обеспечивающий:

#### Основные возможности:

- **Управление тестовыми наборами**: Создание, организация и запуск тестов
- **Параллельное выполнение**: Одновременный запуск множественных тестов
- **Управление зависимостями**: Автоматическое разрешение зависимостей между тестами
- **Отчетность**: Детальные отчеты о результатах тестирования
- **Мемоизация**: Кэширование результатов тестов

#### Использование:

```dart
final framework = TestFramework();
await framework.initialize();

// Создание тестового набора
final suite = framework.createTestSuite(
  suiteId: 'api_tests',
  name: 'API Tests',
  description: 'Тесты для REST API',
  type: TestSuiteType.functional,
);

// Добавление теста
framework.addTest(
  suiteId: 'api_tests',
  testId: 'test_user_creation',
  name: 'Test User Creation',
  testFunction: () async => await testUserCreation(),
  priority: TestPriority.high,
  tags: {'api', 'users'},
);

// Запуск тестов
final result = await framework.runTestSuite('api_tests');
```

### 2. Утилиты тестирования

**Файл:** `lib/testing/test_utilities.dart`

Набор утилит для упрощения создания тестов:

#### Основные возможности:

- **Генерация тестовых данных**: Автоматическое создание тестовых объектов
- **Мок-сервисы**: Имитация внешних зависимостей
- **Тестовые помощники**: Переиспользуемые функции для тестов
- **Ожидание условий**: Утилиты для асинхронного тестирования

#### Использование:

```dart
final utilities = TestUtilities();
await utilities.initialize();

// Генерация тестовых данных
final user = utilities.generateTestUser(
  overrides: {'email': 'custom@test.com'}
);

final message = utilities.generateTestMessage(
  roomId: 'room_123',
  type: MessageType.text,
);

// Создание мок-сервиса
final mockApi = utilities.createMockService('api',
  defaultResponses: {
    'GET /users': {'status': 200, 'data': []}
  }
);

// Ожидание условия
await utilities.waitForCondition(
  () async => await checkSystemReady(),
  timeout: Duration(seconds: 30),
);
```

### 3. Примеры тестов

**Файл:** `test/examples/trust_network_tests.dart`

Готовые примеры тестов для различных компонентов системы:

#### Доступные тестовые наборы:

- **Тесты репутации**: Проверка системы репутации и рекомендаций
- **Тесты доверия**: Верификация системы доверия
- **Интеграционные тесты**: Полные сценарии взаимодействия компонентов

## Конфигурация тестирования

### Основной файл конфигурации

**Файл:** `config/testing.yaml`

Содержит все настройки системы тестирования:

```yaml
testing:
  mode: development
  enabled_test_types: [unit, integration, functional, performance, security, e2e]
  parallel_execution:
    enabled: true
    max_parallel_tests: 4
  timeouts:
    default: 300
    unit_tests: 30
    integration_tests: 120

test_data:
  generation:
    enabled: true
    auto_cleanup: true
  database:
    type: sqlite
    name: test_katya
```

## Типы тестов

### 1. Модульные тесты (Unit Tests)

Тестирование отдельных компонентов в изоляции:

```dart
// Пример модульного теста
framework.addTest(
  suiteId: 'unit_tests',
  testId: 'test_reputation_calculation',
  name: 'Test Reputation Calculation',
  testFunction: () async {
    final service = ReputationService();
    final score = service.calculateScore({
      'interactions': 100,
      'quality': 0.8,
    });

    if (score < 0.0 || score > 1.0) {
      throw Exception('Invalid score range');
    }

    return {'score': score};
  },
  type: TestSuiteType.unit,
);
```

### 2. Интеграционные тесты (Integration Tests)

Тестирование взаимодействия между компонентами:

```dart
// Пример интеграционного теста
framework.addTest(
  suiteId: 'integration_tests',
  testId: 'test_api_database_integration',
  name: 'Test API Database Integration',
  testFunction: () async {
    // Создаем пользователя через API
    final response = await apiClient.createUser({
      'username': 'testuser',
      'email': 'test@example.com',
    });

    // Проверяем, что пользователь сохранен в БД
    final user = await database.getUser(response['id']);

    if (user == null) {
      throw Exception('User not found in database');
    }

    return {'user_id': user.id};
  },
  type: TestSuiteType.integration,
);
```

### 3. Функциональные тесты (Functional Tests)

Тестирование полных пользовательских сценариев:

```dart
// Пример функционального теста
framework.addTest(
  suiteId: 'functional_tests',
  testId: 'test_user_registration_flow',
  name: 'Test User Registration Flow',
  testFunction: () async {
    // Шаг 1: Регистрация пользователя
    final user = utilities.generateTestUser();
    final registrationResult = await authService.register(user);

    // Шаг 2: Подтверждение email
    await emailService.sendConfirmation(user.email);
    await emailService.confirmEmail(user.email, registrationResult.token);

    // Шаг 3: Вход в систему
    final loginResult = await authService.login(user.email, user.password);

    // Шаг 4: Проверка доступа
    final profile = await apiClient.getProfile(loginResult.token);

    if (profile['email'] != user.email) {
      throw Exception('Profile mismatch');
    }

    return {'user_id': user.id, 'token': loginResult.token};
  },
  type: TestSuiteType.functional,
);
```

### 4. Тесты производительности (Performance Tests)

Измерение и проверка производительности:

```dart
// Пример теста производительности
framework.addTest(
  suiteId: 'performance_tests',
  testId: 'test_message_throughput',
  name: 'Test Message Throughput',
  testFunction: () async {
    final startTime = DateTime.now();
    final messageCount = 1000;

    // Отправляем множество сообщений
    final futures = List.generate(messageCount, (i) =>
      messagingService.sendMessage({
        'roomId': 'test_room',
        'content': 'Test message $i',
      })
    );

    await Future.wait(futures);
    final endTime = DateTime.now();

    final duration = endTime.difference(startTime);
    final throughput = messageCount / duration.inSeconds;

    if (throughput < 100) {
      throw Exception('Throughput too low: $throughput msg/s');
    }

    return {
      'throughput': throughput,
      'duration': duration.inMilliseconds,
    };
  },
  type: TestSuiteType.performance,
);
```

### 5. Тесты безопасности (Security Tests)

Проверка безопасности системы:

```dart
// Пример теста безопасности
framework.addTest(
  suiteId: 'security_tests',
  testId: 'test_sql_injection_protection',
  name: 'Test SQL Injection Protection',
  testFunction: () async {
    final maliciousInput = "'; DROP TABLE users; --";

    try {
      await apiClient.searchUsers(maliciousInput);
      // Если не выброшено исключение, проверяем, что таблица не удалена
      final userCount = await database.countUsers();

      if (userCount == 0) {
        throw Exception('SQL injection successful - users table dropped');
      }

      return {'protected': true};
    } catch (e) {
      // Ожидаемое поведение - система должна отклонять подозрительные запросы
      return {'protected': true, 'error': e.toString()};
    }
  },
  type: TestSuiteType.security,
);
```

### 6. End-to-End тесты (E2E Tests)

Тестирование полного пользовательского опыта:

```dart
// Пример E2E теста
framework.addTest(
  suiteId: 'e2e_tests',
  testId: 'test_complete_messaging_flow',
  name: 'Test Complete Messaging Flow',
  testFunction: () async {
    // Открываем веб-приложение
    final browser = await launchBrowser();
    final page = await browser.newPage();

    // Входим в систему
    await page.goto('https://app.katya.wtf/login');
    await page.fill('#email', 'test@example.com');
    await page.fill('#password', 'password123');
    await page.click('#login-button');

    // Создаем комнату
    await page.click('#new-room-button');
    await page.fill('#room-name', 'Test Room');
    await page.click('#create-room-button');

    // Отправляем сообщение
    await page.fill('#message-input', 'Hello, World!');
    await page.click('#send-button');

    // Проверяем, что сообщение отобразилось
    final message = await page.textContent('.message:last-child');

    if (message != 'Hello, World!') {
      throw Exception('Message not displayed correctly');
    }

    await browser.close();
    return {'success': true};
  },
  type: TestSuiteType.e2e,
);
```

## Запуск тестов

### Командная строка

```bash
# Запуск всех тестов
dart run test/run_all_tests.dart

# Запуск конкретного набора тестов
dart run test/run_suite.dart --suite=api_tests

# Запуск тестов по тегам
dart run test/run_tests.dart --tags=api,users

# Запуск тестов производительности
dart run test/run_tests.dart --type=performance

# Параллельный запуск
dart run test/run_tests.dart --parallel --max-parallel=4
```

### Программный запуск

```dart
// Запуск всех тестов
final framework = TestFramework();
await framework.initialize();

final result = await framework.runAllTests(
  options: TestRunOptions(
    parallel: true,
    maxParallelTests: 4,
    suiteTypes: [TestSuiteType.functional, TestSuiteType.integration],
  ),
);

print('Tests completed: ${result.passedTests}/${result.totalTests}');
```

## Отчеты и метрики

### HTML отчеты

Автоматически генерируются HTML отчеты с:

- Детальной информацией о каждом тесте
- Скриншотами для E2E тестов
- Графиками производительности
- Статистикой покрытия кода

### JSON отчеты

Структурированные отчеты для интеграции с CI/CD:

```json
{
  "summary": {
    "total_tests": 150,
    "passed_tests": 145,
    "failed_tests": 5,
    "duration": "00:02:30",
    "success_rate": 0.967
  },
  "suites": [
    {
      "name": "api_tests",
      "passed": 20,
      "failed": 0,
      "duration": "00:00:45"
    }
  ]
}
```

### Метрики покрытия

Автоматический сбор метрик покрытия кода:

- Покрытие строк кода
- Покрытие ветвей
- Покрытие функций
- Покрытие классов

## CI/CD интеграция

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
        with:
          dart-version: stable
      - run: dart pub get
      - run: dart run test/run_all_tests.dart
      - uses: actions/upload-artifact@v2
        with:
          name: test-reports
          path: test_reports/
```

### GitLab CI

```yaml
test:
  stage: test
  image: dart:stable
  script:
    - dart pub get
    - dart run test/run_all_tests.dart
  artifacts:
    reports:
      junit: test_reports/junit.xml
    paths:
      - test_reports/
```

## Рекомендации по написанию тестов

### 1. Структура тестов

```dart
// Хорошая структура теста
framework.addTest(
  suiteId: 'user_tests',
  testId: 'test_user_creation_with_validation',
  name: 'Test User Creation with Validation',
  description: 'Проверяет создание пользователя с валидацией данных',
  testFunction: () async {
    // Arrange - подготовка данных
    final userData = utilities.generateTestUser();

    // Act - выполнение действия
    final result = await userService.createUser(userData);

    // Assert - проверка результата
    if (!result.success) {
      throw Exception('User creation failed: ${result.error}');
    }

    final createdUser = await userService.getUser(result.userId);
    if (createdUser == null) {
      throw Exception('User not found after creation');
    }

    return {
      'user_id': result.userId,
      'created_at': createdUser.createdAt,
    };
  },
  priority: TestPriority.high,
  tags: {'users', 'validation', 'creation'},
);
```

### 2. Использование тегов

```dart
// Теги помогают группировать и фильтровать тесты
tags: {
  'component': 'reputation',    // Компонент системы
  'type': 'calculation',        // Тип операции
  'priority': 'high',          // Приоритет
  'environment': 'production',  // Окружение
}
```

### 3. Обработка ошибок

```dart
// Правильная обработка ошибок в тестах
testFunction: () async {
  try {
    final result = await riskyOperation();
    return {'success': true, 'result': result};
  } catch (e) {
    // Проверяем, что ошибка ожидаемая
    if (e is ExpectedException) {
      return {'success': true, 'expected_error': e.message};
    }

    // Неожиданная ошибка
    throw Exception('Unexpected error: $e');
  }
},
```

### 4. Асинхронные тесты

```dart
// Правильное тестирование асинхронных операций
testFunction: () async {
  // Используем утилиты для ожидания
  await utilities.waitForCondition(
    () async => await checkSystemReady(),
    timeout: Duration(seconds: 30),
  );

  final result = await asyncOperation();

  // Проверяем результат
  await utilities.waitForAsyncOperation(
    () async => await verifyResult(result),
  );

  return {'async_result': result};
},
```

## Отладка тестов

### Логирование

```dart
// Включение детального логирования
testFunction: () async {
  print('Starting test: ${testCase.name}');

  try {
    final result = await operation();
    print('Test completed successfully: $result');
    return result;
  } catch (e) {
    print('Test failed with error: $e');
    rethrow;
  }
},
```

### Изоляция тестов

```dart
// Каждый тест должен быть изолирован
testFunction: () async {
  // Создаем уникальные данные для каждого теста
  final testData = utilities.generateTestUser(
    overrides: {'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com'}
  );

  // Выполняем тест
  final result = await operation(testData);

  // Очищаем данные после теста
  await cleanup(testData);

  return result;
},
```

## Заключение

Система тестирования Katya обеспечивает:

1. **Комплексное покрытие**: Все типы тестов от модульных до E2E
2. **Автоматизацию**: Полная автоматизация процесса тестирования
3. **Производительность**: Параллельное выполнение и оптимизация
4. **Интеграцию**: Готовая интеграция с CI/CD системами
5. **Отчетность**: Детальные отчеты и метрики
6. **Гибкость**: Настраиваемые конфигурации и утилиты

Правильное использование этой системы тестирования обеспечит высокое качество кода, надежность системы и уверенность в развертывании изменений.
