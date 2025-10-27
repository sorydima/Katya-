import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Основной фреймворк для тестирования системы Katya
class TestFramework {
  static final TestFramework _instance = TestFramework._internal();

  // Тестовые данные и результаты
  final Map<String, TestSuite> _testSuites = {};
  final Map<String, TestResult> _testResults = {};
  final List<TestEvent> _testEvents = [];

  // Конфигурация
  static const Duration _defaultTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;

  factory TestFramework() => _instance;
  TestFramework._internal();

  /// Инициализация фреймворка тестирования
  Future<void> initialize() async {
    await _loadTestConfiguration();
    await _initializeTestEnvironment();
  }

  /// Создание тестового набора
  TestSuite createTestSuite({
    required String suiteId,
    required String name,
    required String description,
    List<String>? dependencies,
    TestSuiteType type = TestSuiteType.functional,
    Map<String, dynamic>? configuration,
  }) {
    final suite = TestSuite(
      suiteId: suiteId,
      name: name,
      description: description,
      dependencies: dependencies ?? [],
      type: type,
      configuration: configuration ?? {},
      tests: const [],
      createdAt: DateTime.now(),
      lastRun: null,
      totalRuns: 0,
      successRate: 0.0,
    );

    _testSuites[suiteId] = suite;
    return suite;
  }

  /// Добавление теста в набор
  TestCase addTest({
    required String suiteId,
    required String testId,
    required String name,
    required TestFunction testFunction,
    String? description,
    Duration? timeout,
    int? retries,
    Map<String, dynamic>? tags,
    TestPriority priority = TestPriority.medium,
  }) {
    final suite = _testSuites[suiteId];
    if (suite == null) {
      throw Exception('Test suite not found: $suiteId');
    }

    final testCase = TestCase(
      testId: testId,
      name: name,
      description: description,
      testFunction: testFunction,
      timeout: timeout ?? _defaultTimeout,
      retries: retries ?? _maxRetries,
      tags: tags ?? {},
      priority: priority,
      status: TestStatus.pending,
      createdAt: DateTime.now(),
    );

    suite.tests.add(testCase);
    return testCase;
  }

  /// Запуск тестового набора
  Future<TestSuiteResult> runTestSuite(
    String suiteId, {
    TestRunOptions? options,
  }) async {
    final suite = _testSuites[suiteId];
    if (suite == null) {
      throw Exception('Test suite not found: $suiteId');
    }

    final runOptions = options ?? const TestRunOptions();
    final startTime = DateTime.now();
    final results = <TestCaseResult>[];

    try {
      // Проверяем зависимости
      await _checkDependencies(suite);

      // Подготовка тестовой среды
      await _setupTestEnvironment(suite, runOptions);

      // Запуск тестов
      for (final testCase in suite.tests) {
        if (_shouldRunTest(testCase, runOptions)) {
          final result = await _runTestCase(testCase, runOptions);
          results.add(result);
        }
      }

      // Очистка тестовой среды
      await _cleanupTestEnvironment(suite, runOptions);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final suiteResult = TestSuiteResult(
        suiteId: suiteId,
        success: results.every((r) => r.success),
        totalTests: results.length,
        passedTests: results.where((r) => r.success).length,
        failedTests: results.where((r) => !r.success).length,
        skippedTests: results.where((r) => r.skipped).length,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        results: results,
      );

      // Обновляем статистику набора
      suite.lastRun = endTime;
      suite.totalRuns++;
      suite.successRate = suiteResult.passedTests / suiteResult.totalTests;

      _recordTestEvent(TestEventType.suiteCompleted, suiteId, {
        'success': suiteResult.success,
        'duration': duration.inMilliseconds,
        'passed': suiteResult.passedTests,
        'failed': suiteResult.failedTests,
      });

      return suiteResult;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final suiteResult = TestSuiteResult(
        suiteId: suiteId,
        success: false,
        totalTests: results.length,
        passedTests: results.where((r) => r.success).length,
        failedTests: results.length - results.where((r) => r.success).length,
        skippedTests: 0,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        results: results,
        errorMessage: e.toString(),
      );

      _recordTestEvent(TestEventType.suiteFailed, suiteId, {
        'error': e.toString(),
        'duration': duration.inMilliseconds,
      });

      return suiteResult;
    }
  }

  /// Запуск конкретного теста
  Future<TestCaseResult> runTestCase(
    String suiteId,
    String testId, {
    TestRunOptions? options,
  }) async {
    final suite = _testSuites[suiteId];
    if (suite == null) {
      throw Exception('Test suite not found: $suiteId');
    }

    final testCase = suite.tests.firstWhere(
      (t) => t.testId == testId,
      orElse: () => throw Exception('Test case not found: $testId'),
    );

    final runOptions = options ?? const TestRunOptions();
    await _setupTestEnvironment(suite, runOptions);

    try {
      final result = await _runTestCase(testCase, runOptions);
      await _cleanupTestEnvironment(suite, runOptions);
      return result;
    } catch (e) {
      await _cleanupTestEnvironment(suite, runOptions);
      rethrow;
    }
  }

  /// Запуск всех тестовых наборов
  Future<TestRunResult> runAllTests({TestRunOptions? options}) async {
    final runOptions = options ?? const TestRunOptions();
    final startTime = DateTime.now();
    final suiteResults = <TestSuiteResult>[];

    // Сортируем наборы по зависимостям
    final sortedSuites = _sortSuitesByDependencies();

    for (final suite in sortedSuites) {
      if (_shouldRunSuite(suite, runOptions)) {
        final result = await runTestSuite(suite.suiteId, options: runOptions);
        suiteResults.add(result);
      }
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    return TestRunResult(
      success: suiteResults.every((r) => r.success),
      totalSuites: suiteResults.length,
      passedSuites: suiteResults.where((r) => r.success).length,
      failedSuites: suiteResults.where((r) => !r.success).length,
      totalTests: suiteResults.fold(0, (sum, r) => sum + r.totalTests),
      passedTests: suiteResults.fold(0, (sum, r) => sum + r.passedTests),
      failedTests: suiteResults.fold(0, (sum, r) => sum + r.failedTests),
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      suiteResults: suiteResults,
    );
  }

  /// Создание мок-объекта
  MockObject createMock<T>(String name, {Map<String, dynamic>? defaultResponses}) {
    return MockObject(
      name: name,
      type: T.toString(),
      defaultResponses: defaultResponses ?? {},
      callHistory: const [],
      createdAt: DateTime.now(),
    );
  }

  /// Создание фикстуры
  TestFixture createFixture(
    String name,
    FixtureFunction setupFunction, {
    FixtureFunction? teardownFunction,
    FixtureScope scope = FixtureScope.test,
  }) {
    return TestFixture(
      name: name,
      setupFunction: setupFunction,
      teardownFunction: teardownFunction,
      scope: scope,
      isActive: false,
      createdAt: DateTime.now(),
    );
  }

  /// Генерация тестовых данных
  TestDataGenerator createDataGenerator(
    String name, {
    Map<String, dynamic>? templates,
  }) {
    return TestDataGenerator(
      name: name,
      templates: templates ?? {},
      createdAt: DateTime.now(),
    );
  }

  /// Получение результатов тестирования
  List<TestResult> getTestResults({
    String? suiteId,
    String? testId,
    TestStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var results = _testResults.values.toList();

    if (suiteId != null) {
      results = results.where((r) => r.suiteId == suiteId).toList();
    }

    if (testId != null) {
      results = results.where((r) => r.testId == testId).toList();
    }

    if (status != null) {
      results = results.where((r) => r.status == status).toList();
    }

    if (startDate != null) {
      results = results.where((r) => r.startTime.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      results = results.where((r) => r.endTime.isBefore(endDate)).toList();
    }

    results.sort((a, b) => b.startTime.compareTo(a.startTime));
    return results;
  }

  /// Получение отчета о тестировании
  TestReport generateReport({
    DateTime? startDate,
    DateTime? endDate,
    String? suiteId,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 7));

    final relevantResults = _testResults.values
        .where((r) => r.startTime.isAfter(start) && r.endTime.isBefore(end))
        .where((r) => suiteId == null || r.suiteId == suiteId)
        .toList();

    if (relevantResults.isEmpty) {
      return TestReport(
        periodStart: start,
        periodEnd: end,
        totalTests: 0,
        passedTests: 0,
        failedTests: 0,
        skippedTests: 0,
        successRate: 0.0,
        averageDuration: Duration.zero,
        totalDuration: Duration.zero,
        coverage: 0.0,
      );
    }

    final totalTests = relevantResults.length;
    final passedTests = relevantResults.where((r) => r.success).length;
    final failedTests = relevantResults.where((r) => !r.success).length;
    final skippedTests = relevantResults.where((r) => r.skipped).length;

    final durations = relevantResults.map((r) => r.duration).toList();
    final totalDuration = Duration(
      milliseconds: durations.fold(0, (sum, d) => sum + d.inMilliseconds),
    );
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ durations.length,
    );

    return TestReport(
      periodStart: start,
      periodEnd: end,
      totalTests: totalTests,
      passedTests: passedTests,
      failedTests: failedTests,
      skippedTests: skippedTests,
      successRate: passedTests / totalTests,
      averageDuration: averageDuration,
      totalDuration: totalDuration,
      coverage: _calculateCoverage(relevantResults),
    );
  }

  /// Проверка зависимостей
  Future<void> _checkDependencies(TestSuite suite) async {
    for (final dependency in suite.dependencies) {
      final dependencySuite = _testSuites[dependency];
      if (dependencySuite == null) {
        throw Exception('Dependency not found: $dependency');
      }

      if (dependencySuite.lastRun == null || !dependencySuite.successRate > 0.8) {
        throw Exception('Dependency $dependency not satisfied');
      }
    }
  }

  /// Настройка тестовой среды
  Future<void> _setupTestEnvironment(TestSuite suite, TestRunOptions options) async {
    _recordTestEvent(TestEventType.environmentSetup, suite.suiteId, {});

    // Настройка базы данных
    if (options.setupDatabase) {
      await _setupTestDatabase();
    }

    // Настройка мок-сервисов
    if (options.setupMocks) {
      await _setupMockServices();
    }

    // Очистка временных данных
    if (options.cleanupBeforeTest) {
      await _cleanupTempData();
    }
  }

  /// Очистка тестовой среды
  Future<void> _cleanupTestEnvironment(TestSuite suite, TestRunOptions options) async {
    _recordTestEvent(TestEventType.environmentCleanup, suite.suiteId, {});

    // Очистка базы данных
    if (options.cleanupDatabase) {
      await _cleanupTestDatabase();
    }

    // Очистка мок-сервисов
    if (options.cleanupMocks) {
      await _cleanupMockServices();
    }

    // Очистка временных файлов
    if (options.cleanupTempFiles) {
      await _cleanupTempFiles();
    }
  }

  /// Запуск тестового случая
  Future<TestCaseResult> _runTestCase(TestCase testCase, TestRunOptions options) async {
    final startTime = DateTime.now();
    int attempts = 0;
    Exception? lastException;

    while (attempts < testCase.retries) {
      attempts++;

      try {
        testCase.status = TestStatus.running;
        _recordTestEvent(TestEventType.testStarted, testCase.testId, {
          'attempt': attempts,
          'maxAttempts': testCase.retries,
        });

        final result = await testCase.testFunction().timeout(testCase.timeout);

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        final testResult = TestCaseResult(
          testId: testCase.testId,
          success: true,
          skipped: false,
          duration: duration,
          startTime: startTime,
          endTime: endTime,
          result: result,
          attempts: attempts,
        );

        testCase.status = TestStatus.passed;
        _testResults['${testCase.testId}_${startTime.millisecondsSinceEpoch}'] = TestResult(
          suiteId: '',
          testId: testCase.testId,
          success: true,
          skipped: false,
          duration: duration,
          startTime: startTime,
          endTime: endTime,
          result: result,
          attempts: attempts,
        );

        _recordTestEvent(TestEventType.testPassed, testCase.testId, {
          'duration': duration.inMilliseconds,
          'attempts': attempts,
        });

        return testResult;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (attempts < testCase.retries) {
          _recordTestEvent(TestEventType.testRetry, testCase.testId, {
            'attempt': attempts,
            'error': e.toString(),
          });
          await Future.delayed(Duration(milliseconds: 100 * attempts));
        }
      }
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final testResult = TestCaseResult(
      testId: testCase.testId,
      success: false,
      skipped: false,
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      errorMessage: lastException?.toString(),
      attempts: attempts,
    );

    testCase.status = TestStatus.failed;
    _testResults['${testCase.testId}_${startTime.millisecondsSinceEpoch}'] = TestResult(
      suiteId: '',
      testId: testCase.testId,
      success: false,
      skipped: false,
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      errorMessage: lastException?.toString(),
      attempts: attempts,
    );

    _recordTestEvent(TestEventType.testFailed, testCase.testId, {
      'duration': duration.inMilliseconds,
      'attempts': attempts,
      'error': lastException?.toString(),
    });

    return testResult;
  }

  /// Проверка необходимости запуска теста
  bool _shouldRunTest(TestCase testCase, TestRunOptions options) {
    if (options.testIds.isNotEmpty && !options.testIds.contains(testCase.testId)) {
      return false;
    }

    if (options.tags.isNotEmpty) {
      final hasMatchingTag = testCase.tags.keys.any((tag) => options.tags.contains(tag));
      if (!hasMatchingTag) return false;
    }

    if (options.priorities.isNotEmpty && !options.priorities.contains(testCase.priority)) {
      return false;
    }

    return true;
  }

  /// Проверка необходимости запуска набора
  bool _shouldRunSuite(TestSuite suite, TestRunOptions options) {
    if (options.suiteIds.isNotEmpty && !options.suiteIds.contains(suite.suiteId)) {
      return false;
    }

    if (options.suiteTypes.isNotEmpty && !options.suiteTypes.contains(suite.type)) {
      return false;
    }

    return true;
  }

  /// Сортировка наборов по зависимостям
  List<TestSuite> _sortSuitesByDependencies() {
    final sorted = <TestSuite>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(TestSuite suite) {
      if (visiting.contains(suite.suiteId)) {
        throw Exception('Circular dependency detected');
      }

      if (visited.contains(suite.suiteId)) {
        return;
      }

      visiting.add(suite.suiteId);

      for (final dependencyId in suite.dependencies) {
        final dependency = _testSuites[dependencyId];
        if (dependency != null) {
          visit(dependency);
        }
      }

      visiting.remove(suite.suiteId);
      visited.add(suite.suiteId);
      sorted.add(suite);
    }

    for (final suite in _testSuites.values) {
      visit(suite);
    }

    return sorted;
  }

  /// Расчет покрытия тестами
  double _calculateCoverage(List<TestResult> results) {
    // Упрощенный расчет покрытия
    const totalLines = 10000; // Имитация общего количества строк кода
    final coveredLines = results.where((r) => r.success).length * 100;
    return coveredLines / totalLines;
  }

  /// Запись события тестирования
  void _recordTestEvent(TestEventType type, String source, Map<String, dynamic> data) {
    final event = TestEvent(
      id: _generateId(),
      type: type,
      source: source,
      data: data,
      timestamp: DateTime.now(),
    );

    _testEvents.add(event);

    // Ограничиваем количество событий в памяти
    if (_testEvents.length > 10000) {
      _testEvents.removeRange(0, _testEvents.length - 5000);
    }
  }

  /// Загрузка конфигурации тестирования
  Future<void> _loadTestConfiguration() async {
    // В реальной реализации здесь будет загрузка из файлов конфигурации
  }

  /// Инициализация тестовой среды
  Future<void> _initializeTestEnvironment() async {
    // Инициализация тестовой базы данных, мок-сервисов и т.д.
  }

  /// Настройка тестовой базы данных
  Future<void> _setupTestDatabase() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Настройка мок-сервисов
  Future<void> _setupMockServices() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Очистка временных данных
  Future<void> _cleanupTempData() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Очистка тестовой базы данных
  Future<void> _cleanupTestDatabase() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Очистка мок-сервисов
  Future<void> _cleanupMockServices() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Очистка временных файлов
  Future<void> _cleanupTempFiles() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Генерация уникального ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _testSuites.clear();
    _testResults.clear();
    _testEvents.clear();
  }
}

/// Модели данных

/// Тестовый набор
class TestSuite extends Equatable {
  final String suiteId;
  final String name;
  final String description;
  final List<String> dependencies;
  final TestSuiteType type;
  final Map<String, dynamic> configuration;
  final List<TestCase> tests;
  final DateTime createdAt;
  DateTime? lastRun;
  int totalRuns;
  double successRate;

  TestSuite({
    required this.suiteId,
    required this.name,
    required this.description,
    required this.dependencies,
    required this.type,
    required this.configuration,
    required this.tests,
    required this.createdAt,
    this.lastRun,
    required this.totalRuns,
    required this.successRate,
  });

  @override
  List<Object?> get props => [
        suiteId,
        name,
        description,
        dependencies,
        type,
        configuration,
        tests,
        createdAt,
        lastRun,
        totalRuns,
        successRate,
      ];
}

/// Тестовый случай
class TestCase extends Equatable {
  final String testId;
  final String name;
  final String? description;
  final TestFunction testFunction;
  final Duration timeout;
  final int retries;
  final Map<String, dynamic> tags;
  final TestPriority priority;
  TestStatus status;
  final DateTime createdAt;

  TestCase({
    required this.testId,
    required this.name,
    this.description,
    required this.testFunction,
    required this.timeout,
    required this.retries,
    required this.tags,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        testId,
        name,
        description,
        timeout,
        retries,
        tags,
        priority,
        status,
        createdAt,
      ];
}

/// Результат тестового набора
class TestSuiteResult extends Equatable {
  final String suiteId;
  final bool success;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<TestCaseResult> results;
  final String? errorMessage;

  const TestSuiteResult({
    required this.suiteId,
    required this.success,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.skippedTests,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.results,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        suiteId,
        success,
        totalTests,
        passedTests,
        failedTests,
        skippedTests,
        duration,
        startTime,
        endTime,
        results,
        errorMessage,
      ];
}

/// Результат тестового случая
class TestCaseResult extends Equatable {
  final String testId;
  final bool success;
  final bool skipped;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final dynamic result;
  final String? errorMessage;
  final int attempts;

  const TestCaseResult({
    required this.testId,
    required this.success,
    required this.skipped,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.result,
    this.errorMessage,
    required this.attempts,
  });

  @override
  List<Object?> get props => [
        testId,
        success,
        skipped,
        duration,
        startTime,
        endTime,
        result,
        errorMessage,
        attempts,
      ];
}

/// Результат запуска тестов
class TestRunResult extends Equatable {
  final bool success;
  final int totalSuites;
  final int passedSuites;
  final int failedSuites;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<TestSuiteResult> suiteResults;

  const TestRunResult({
    required this.success,
    required this.totalSuites,
    required this.passedSuites,
    required this.failedSuites,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.suiteResults,
  });

  @override
  List<Object?> get props => [
        success,
        totalSuites,
        passedSuites,
        failedSuites,
        totalTests,
        passedTests,
        failedTests,
        duration,
        startTime,
        endTime,
        suiteResults,
      ];
}

/// Результат теста
class TestResult extends Equatable {
  final String suiteId;
  final String testId;
  final bool success;
  final bool skipped;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final dynamic result;
  final String? errorMessage;
  final int attempts;

  const TestResult({
    required this.suiteId,
    required this.testId,
    required this.success,
    required this.skipped,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.result,
    this.errorMessage,
    required this.attempts,
  });

  @override
  List<Object?> get props => [
        suiteId,
        testId,
        success,
        skipped,
        duration,
        startTime,
        endTime,
        result,
        errorMessage,
        attempts,
      ];
}

/// Отчет о тестировании
class TestReport extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  final double successRate;
  final Duration averageDuration;
  final Duration totalDuration;
  final double coverage;

  const TestReport({
    required this.periodStart,
    required this.periodEnd,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.skippedTests,
    required this.successRate,
    required this.averageDuration,
    required this.totalDuration,
    required this.coverage,
  });

  @override
  List<Object?> get props => [
        periodStart,
        periodEnd,
        totalTests,
        passedTests,
        failedTests,
        skippedTests,
        successRate,
        averageDuration,
        totalDuration,
        coverage,
      ];
}

/// Событие тестирования
class TestEvent extends Equatable {
  final String id;
  final TestEventType type;
  final String source;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const TestEvent({
    required this.id,
    required this.type,
    required this.source,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, source, data, timestamp];
}

/// Мок-объект
class MockObject extends Equatable {
  final String name;
  final String type;
  final Map<String, dynamic> defaultResponses;
  final List<MockCall> callHistory;
  final DateTime createdAt;

  const MockObject({
    required this.name,
    required this.type,
    required this.defaultResponses,
    required this.callHistory,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, type, defaultResponses, callHistory, createdAt];
}

/// Вызов мок-объекта
class MockCall extends Equatable {
  final String method;
  final List<dynamic> arguments;
  final dynamic result;
  final DateTime timestamp;

  const MockCall({
    required this.method,
    required this.arguments,
    required this.result,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [method, arguments, result, timestamp];
}

/// Тестовая фикстура
class TestFixture extends Equatable {
  final String name;
  final FixtureFunction setupFunction;
  final FixtureFunction? teardownFunction;
  final FixtureScope scope;
  bool isActive;
  final DateTime createdAt;

  TestFixture({
    required this.name,
    required this.setupFunction,
    this.teardownFunction,
    required this.scope,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, setupFunction, teardownFunction, scope, isActive, createdAt];
}

/// Генератор тестовых данных
class TestDataGenerator extends Equatable {
  final String name;
  final Map<String, dynamic> templates;
  final DateTime createdAt;

  const TestDataGenerator({
    required this.name,
    required this.templates,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [name, templates, createdAt];
}

/// Опции запуска тестов
class TestRunOptions extends Equatable {
  final List<String> suiteIds;
  final List<String> testIds;
  final List<TestSuiteType> suiteTypes;
  final List<String> tags;
  final List<TestPriority> priorities;
  final bool setupDatabase;
  final bool setupMocks;
  final bool cleanupBeforeTest;
  final bool cleanupDatabase;
  final bool cleanupMocks;
  final bool cleanupTempFiles;
  final bool parallel;
  final int maxParallelTests;

  const TestRunOptions({
    this.suiteIds = const [],
    this.testIds = const [],
    this.suiteTypes = const [],
    this.tags = const [],
    this.priorities = const [],
    this.setupDatabase = true,
    this.setupMocks = true,
    this.cleanupBeforeTest = true,
    this.cleanupDatabase = true,
    this.cleanupMocks = true,
    this.cleanupTempFiles = true,
    this.parallel = false,
    this.maxParallelTests = 4,
  });

  @override
  List<Object?> get props => [
        suiteIds,
        testIds,
        suiteTypes,
        tags,
        priorities,
        setupDatabase,
        setupMocks,
        cleanupBeforeTest,
        cleanupDatabase,
        cleanupMocks,
        cleanupTempFiles,
        parallel,
        maxParallelTests,
      ];
}

/// Перечисления

/// Функция теста
typedef TestFunction = Future<dynamic> Function();

/// Функция фикстуры
typedef FixtureFunction = Future<void> Function();

/// Тип тестового набора
enum TestSuiteType {
  unit, // Модульные тесты
  integration, // Интеграционные тесты
  functional, // Функциональные тесты
  performance, // Тесты производительности
  security, // Тесты безопасности
  e2e, // End-to-end тесты
}

/// Приоритет теста
enum TestPriority {
  low, // Низкий
  medium, // Средний
  high, // Высокий
  critical, // Критический
}

/// Статус теста
enum TestStatus {
  pending, // Ожидает
  running, // Выполняется
  passed, // Пройден
  failed, // Провален
  skipped, // Пропущен
}

/// Тип события тестирования
enum TestEventType {
  suiteStarted,
  suiteCompleted,
  suiteFailed,
  testStarted,
  testPassed,
  testFailed,
  testRetry,
  testSkipped,
  environmentSetup,
  environmentCleanup,
}

/// Область действия фикстуры
enum FixtureScope {
  test, // Для одного теста
  suite, // Для набора тестов
  session, // Для сессии тестирования
}
