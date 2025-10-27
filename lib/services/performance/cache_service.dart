import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Сервис кэширования для оптимизации производительности
class CacheService {
  static final CacheService _instance = CacheService._internal();

  // Кэши в памяти
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, CacheStatistics> _cacheStats = {};

  // Конфигурация
  static const int _maxMemoryCacheSize = 10000;
  static const Duration _defaultTtl = Duration(hours: 1);
  static const Duration _cleanupInterval = Duration(minutes: 10);

  // Таймеры
  Timer? _cleanupTimer;
  Timer? _statsTimer;

  factory CacheService() => _instance;
  CacheService._internal();

  /// Инициализация сервиса кэширования
  Future<void> initialize() async {
    _setupCacheCleanup();
    _setupStatsCollection();
    await _loadCacheConfiguration();
  }

  /// Получение значения из кэша
  Future<T?> get<T>(String key, {String? namespace}) async {
    final cacheKey = _buildCacheKey(key, namespace);
    final stats = _getCacheStats(cacheKey);

    try {
      // Проверяем кэш в памяти
      final entry = _memoryCache[cacheKey];
      if (entry != null && !entry.isExpired) {
        stats.hits++;
        stats.lastAccess = DateTime.now();
        return _deserializeValue<T>(entry.value);
      }

      // Если не найдено в памяти, пробуем внешний кэш (Redis)
      final externalValue = await _getFromExternalCache(cacheKey);
      if (externalValue != null) {
        // Сохраняем в памяти для быстрого доступа
        await _setMemoryCache(cacheKey, externalValue, entry?.ttl ?? _defaultTtl);
        stats.hits++;
        stats.lastAccess = DateTime.now();
        return _deserializeValue<T>(externalValue);
      }

      stats.misses++;
      stats.lastAccess = DateTime.now();
      return null;
    } catch (e) {
      stats.errors++;
      return null;
    }
  }

  /// Сохранение значения в кэш
  Future<bool> set<T>(
    String key,
    T value, {
    String? namespace,
    Duration? ttl,
    CacheWritePolicy writePolicy = CacheWritePolicy.writeThrough,
  }) async {
    final cacheKey = _buildCacheKey(key, namespace);
    final stats = _getCacheStats(cacheKey);
    final cacheTtl = ttl ?? _defaultTtl;

    try {
      final serializedValue = _serializeValue(value);

      switch (writePolicy) {
        case CacheWritePolicy.writeThrough:
          // Записываем в память и внешний кэш одновременно
          await _setMemoryCache(cacheKey, serializedValue, cacheTtl);
          await _setExternalCache(cacheKey, serializedValue, cacheTtl);
        case CacheWritePolicy.writeBack:
          // Записываем только в память, внешний кэш обновим позже
          await _setMemoryCache(cacheKey, serializedValue, cacheTtl);
          _scheduleWriteBack(cacheKey, serializedValue, cacheTtl);
        case CacheWritePolicy.writeAround:
          // Записываем только во внешний кэш
          await _setExternalCache(cacheKey, serializedValue, cacheTtl);
      }

      stats.writes++;
      stats.lastWrite = DateTime.now();
      return true;
    } catch (e) {
      stats.errors++;
      return false;
    }
  }

  /// Удаление значения из кэша
  Future<bool> delete(String key, {String? namespace}) async {
    final cacheKey = _buildCacheKey(key, namespace);
    final stats = _getCacheStats(cacheKey);

    try {
      // Удаляем из памяти
      _memoryCache.remove(cacheKey);

      // Удаляем из внешнего кэша
      await _deleteFromExternalCache(cacheKey);

      stats.deletes++;
      stats.lastAccess = DateTime.now();
      return true;
    } catch (e) {
      stats.errors++;
      return false;
    }
  }

  /// Проверка существования ключа в кэше
  Future<bool> exists(String key, {String? namespace}) async {
    final cacheKey = _buildCacheKey(key, namespace);

    // Проверяем память
    final entry = _memoryCache[cacheKey];
    if (entry != null && !entry.isExpired) {
      return true;
    }

    // Проверяем внешний кэш
    return await _existsInExternalCache(cacheKey);
  }

  /// Получение множественных значений
  Future<Map<String, T>> getMany<T>(List<String> keys, {String? namespace}) async {
    final result = <String, T>{};

    // Параллельная обработка ключей
    final futures = keys.map((key) async {
      final value = await get<T>(key, namespace: namespace);
      if (value != null) {
        result[key] = value;
      }
    });

    await Future.wait(futures);
    return result;
  }

  /// Сохранение множественных значений
  Future<Map<String, bool>> setMany<T>(
    Map<String, T> values, {
    String? namespace,
    Duration? ttl,
    CacheWritePolicy writePolicy = CacheWritePolicy.writeThrough,
  }) async {
    final results = <String, bool>{};

    // Параллельная обработка значений
    final futures = values.entries.map((entry) async {
      final success = await set(
        entry.key,
        entry.value,
        namespace: namespace,
        ttl: ttl,
        writePolicy: writePolicy,
      );
      results[entry.key] = success;
    });

    await Future.wait(futures);
    return results;
  }

  /// Очистка кэша по паттерну
  Future<int> clearByPattern(String pattern, {String? namespace}) async {
    final cachePattern = namespace != null ? '$namespace:$pattern' : pattern;
    int clearedCount = 0;

    try {
      // Очищаем память
      final keysToRemove = _memoryCache.keys.where((key) => _matchesPattern(key, cachePattern)).toList();

      for (final key in keysToRemove) {
        _memoryCache.remove(key);
        clearedCount++;
      }

      // Очищаем внешний кэш
      final externalCleared = await _clearExternalCacheByPattern(cachePattern);
      clearedCount += externalCleared;

      return clearedCount;
    } catch (e) {
      return clearedCount;
    }
  }

  /// Получение статистики кэша
  CacheServiceStatistics getStatistics({String? namespace}) {
    final allStats = _cacheStats.values.toList();

    if (namespace != null) {
      final filteredStats = allStats.where((stats) => stats.key.startsWith('$namespace:')).toList();
      return _aggregateStats(filteredStats);
    }

    return _aggregateStats(allStats);
  }

  /// Получение статистики по конкретному ключу
  CacheStatistics? getKeyStatistics(String key, {String? namespace}) {
    final cacheKey = _buildCacheKey(key, namespace);
    return _cacheStats[cacheKey];
  }

  /// Очистка всего кэша
  Future<void> clearAll() async {
    _memoryCache.clear();
    await _clearAllExternalCache();
    _cacheStats.clear();
  }

  /// Оптимизация кэша
  Future<CacheOptimizationResult> optimizeCache() async {
    final startTime = DateTime.now();
    int optimizedEntries = 0;
    int freedMemory = 0;

    try {
      // Удаляем истекшие записи
      final expiredKeys =
          _memoryCache.entries.where((entry) => entry.value.isExpired).map((entry) => entry.key).toList();

      for (final key in expiredKeys) {
        final entry = _memoryCache.remove(key);
        if (entry != null) {
          freedMemory += entry.size;
          optimizedEntries++;
        }
      }

      // Оптимизируем размер кэша
      if (_memoryCache.length > _maxMemoryCacheSize) {
        final sortedEntries = _memoryCache.entries.toList()
          ..sort((a, b) => a.value.lastAccess.compareTo(b.value.lastAccess));

        final toRemove = sortedEntries.take(
          _memoryCache.length - _maxMemoryCacheSize,
        );

        for (final entry in toRemove) {
          _memoryCache.remove(entry.key);
          freedMemory += entry.value.size;
          optimizedEntries++;
        }
      }

      // Оптимизируем внешний кэш
      await _optimizeExternalCache();

      final duration = DateTime.now().difference(startTime);

      return CacheOptimizationResult(
        success: true,
        optimizedEntries: optimizedEntries,
        freedMemory: freedMemory,
        duration: duration,
      );
    } catch (e) {
      return CacheOptimizationResult(
        success: false,
        optimizedEntries: optimizedEntries,
        freedMemory: freedMemory,
        errorMessage: e.toString(),
      );
    }
  }

  /// Создание кэшированной функции
  Future<T> memoize<T>(
    String key,
    Future<T> Function() computation, {
    String? namespace,
    Duration? ttl,
  }) async {
    final cachedValue = await get<T>(key, namespace: namespace);
    if (cachedValue != null) {
      return cachedValue;
    }

    final computedValue = await computation();
    await set(key, computedValue, namespace: namespace, ttl: ttl);
    return computedValue;
  }

  /// Построение ключа кэша
  String _buildCacheKey(String key, String? namespace) {
    return namespace != null ? '$namespace:$key' : key;
  }

  /// Получение статистики кэша
  CacheStatistics _getCacheStats(String key) {
    return _cacheStats.putIfAbsent(
        key,
        () => CacheStatistics(
              key: key,
              hits: 0,
              misses: 0,
              writes: 0,
              deletes: 0,
              errors: 0,
              lastAccess: DateTime.now(),
              lastWrite: null,
              createdAt: DateTime.now(),
            ));
  }

  /// Сохранение в кэш памяти
  Future<void> _setMemoryCache(String key, String value, Duration ttl) async {
    final entry = CacheEntry(
      key: key,
      value: value,
      ttl: ttl,
      createdAt: DateTime.now(),
      lastAccess: DateTime.now(),
      size: value.length * 2, // Примерная оценка размера
    );

    _memoryCache[key] = entry;
  }

  /// Сериализация значения
  String _serializeValue<T>(T value) {
    if (value is String) return value;
    if (value is Map || value is List) {
      return jsonEncode(value);
    }
    return value.toString();
  }

  /// Десериализация значения
  T? _deserializeValue<T>(String value) {
    if (T == String) return value as T;

    try {
      if (T == Map || T == List) {
        return jsonDecode(value) as T;
      }
    } catch (e) {
      // Если не удается десериализовать, возвращаем как строку
    }

    return value as T;
  }

  /// Проверка соответствия паттерну
  bool _matchesPattern(String key, String pattern) {
    if (pattern.contains('*')) {
      final regexPattern = pattern.replaceAll('*', '.*');
      final regex = RegExp('^$regexPattern\$');
      return regex.hasMatch(key);
    }
    return key == pattern;
  }

  /// Агрегация статистики
  CacheServiceStatistics _aggregateStats(List<CacheStatistics> stats) {
    if (stats.isEmpty) {
      return const CacheServiceStatistics(
        totalKeys: 0,
        totalHits: 0,
        totalMisses: 0,
        totalWrites: 0,
        totalDeletes: 0,
        totalErrors: 0,
        hitRate: 0.0,
        memoryUsage: 0,
        averageResponseTime: Duration.zero,
      );
    }

    final totalHits = stats.fold(0, (sum, stat) => sum + stat.hits);
    final totalMisses = stats.fold(0, (sum, stat) => sum + stat.misses);
    final totalRequests = totalHits + totalMisses;
    final hitRate = totalRequests > 0 ? totalHits / totalRequests : 0.0;

    return CacheServiceStatistics(
      totalKeys: stats.length,
      totalHits: totalHits,
      totalMisses: totalMisses,
      totalWrites: stats.fold(0, (sum, stat) => sum + stat.writes),
      totalDeletes: stats.fold(0, (sum, stat) => sum + stat.deletes),
      totalErrors: stats.fold(0, (sum, stat) => sum + stat.errors),
      hitRate: hitRate,
      memoryUsage: _memoryCache.values.fold(0, (sum, entry) => sum + entry.size),
      averageResponseTime: const Duration(milliseconds: 5), // Имитация
    );
  }

  /// Настройка очистки кэша
  void _setupCacheCleanup() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) async {
      await _cleanupExpiredEntries();
    });
  }

  /// Настройка сбора статистики
  void _setupStatsCollection() {
    _statsTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _collectStatistics();
    });
  }

  /// Загрузка конфигурации кэша
  Future<void> _loadCacheConfiguration() async {
    // В реальной реализации здесь будет загрузка из конфигурационных файлов
  }

  /// Очистка истекших записей
  Future<void> _cleanupExpiredEntries() async {
    final expiredKeys = _memoryCache.entries.where((entry) => entry.value.isExpired).map((entry) => entry.key).toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    // Очищаем внешний кэш
    await _cleanupExpiredExternalCache();
  }

  /// Сбор статистики
  Future<void> _collectStatistics() async {
    // В реальной реализации здесь будет сбор и отправка статистики
  }

  /// Планирование отложенной записи
  void _scheduleWriteBack(String key, String value, Duration ttl) {
    Timer(const Duration(seconds: 30), () async {
      await _setExternalCache(key, value, ttl);
    });
  }

  /// Внешний кэш операции (Redis имитация)
  Future<String?> _getFromExternalCache(String key) async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 2));
    return null; // Для демонстрации возвращаем null
  }

  Future<void> _setExternalCache(String key, String value, Duration ttl) async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 3));
  }

  Future<void> _deleteFromExternalCache(String key) async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 2));
  }

  Future<bool> _existsInExternalCache(String key) async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 1));
    return false;
  }

  Future<int> _clearExternalCacheByPattern(String pattern) async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 5));
    return 0;
  }

  Future<void> _clearAllExternalCache() async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> _cleanupExpiredExternalCache() async {
    // Имитация Redis
    await Future.delayed(const Duration(milliseconds: 2));
  }

  Future<void> _optimizeExternalCache() async {
    // Имитация Redis оптимизации
    await Future.delayed(const Duration(milliseconds: 5));
  }

  /// Освобождение ресурсов
  void dispose() {
    _cleanupTimer?.cancel();
    _statsTimer?.cancel();
    _memoryCache.clear();
    _cacheStats.clear();
  }
}

/// Модели данных

/// Запись в кэше
class CacheEntry extends Equatable {
  final String key;
  final String value;
  final Duration ttl;
  final DateTime createdAt;
  DateTime lastAccess;
  final int size;

  CacheEntry({
    required this.key,
    required this.value,
    required this.ttl,
    required this.createdAt,
    required this.lastAccess,
    required this.size,
  });

  bool get isExpired {
    return DateTime.now().difference(createdAt) > ttl;
  }

  @override
  List<Object?> get props => [key, value, ttl, createdAt, lastAccess, size];
}

/// Статистика кэша
class CacheStatistics extends Equatable {
  final String key;
  int hits;
  int misses;
  int writes;
  int deletes;
  int errors;
  DateTime lastAccess;
  DateTime? lastWrite;
  final DateTime createdAt;

  CacheStatistics({
    required this.key,
    required this.hits,
    required this.misses,
    required this.writes,
    required this.deletes,
    required this.errors,
    required this.lastAccess,
    this.lastWrite,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        key,
        hits,
        misses,
        writes,
        deletes,
        errors,
        lastAccess,
        lastWrite,
        createdAt,
      ];
}

/// Общая статистика сервиса кэширования
class CacheServiceStatistics extends Equatable {
  final int totalKeys;
  final int totalHits;
  final int totalMisses;
  final int totalWrites;
  final int totalDeletes;
  final int totalErrors;
  final double hitRate;
  final int memoryUsage;
  final Duration averageResponseTime;

  const CacheServiceStatistics({
    required this.totalKeys,
    required this.totalHits,
    required this.totalMisses,
    required this.totalWrites,
    required this.totalDeletes,
    required this.totalErrors,
    required this.hitRate,
    required this.memoryUsage,
    required this.averageResponseTime,
  });

  @override
  List<Object?> get props => [
        totalKeys,
        totalHits,
        totalMisses,
        totalWrites,
        totalDeletes,
        totalErrors,
        hitRate,
        memoryUsage,
        averageResponseTime,
      ];
}

/// Результат оптимизации кэша
class CacheOptimizationResult extends Equatable {
  final bool success;
  final int optimizedEntries;
  final int freedMemory;
  final Duration duration;
  final String? errorMessage;

  const CacheOptimizationResult({
    required this.success,
    required this.optimizedEntries,
    required this.freedMemory,
    required this.duration,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, optimizedEntries, freedMemory, duration, errorMessage];
}

/// Политика записи в кэш
enum CacheWritePolicy {
  writeThrough, // Запись в память и внешний кэш одновременно
  writeBack, // Запись в память, внешний кэш обновляется позже
  writeAround, // Запись только во внешний кэш
}
