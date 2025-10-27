import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

/// Сервис для интеграции с внешними API и сервисами
class ExternalApiIntegrationService {
  static final ExternalApiIntegrationService _instance = ExternalApiIntegrationService._internal();

  // Интегрированные API
  final Map<String, ExternalApi> _integratedApis = {};
  final Map<String, ApiRateLimit> _rateLimits = {};
  final Map<String, ApiCache> _apiCache = {};

  // HTTP клиент
  late final http.Client _httpClient;

  // Конфигурация
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _cacheTimeout = Duration(minutes: 15);
  static const int _maxCacheSize = 1000;

  factory ExternalApiIntegrationService() => _instance;
  ExternalApiIntegrationService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    _httpClient = http.Client();
    await _loadApiConfigurations();
    _setupRateLimitMonitoring();
    _setupCacheCleanup();
  }

  /// Регистрация внешнего API
  Future<ApiRegistrationResult> registerApi({
    required String apiId,
    required String name,
    required String baseUrl,
    required ApiAuthentication authentication,
    Map<String, String>? defaultHeaders,
    Duration? timeout,
    int? rateLimitPerMinute,
  }) async {
    try {
      final api = ExternalApi(
        apiId: apiId,
        name: name,
        baseUrl: baseUrl,
        authentication: authentication,
        defaultHeaders: defaultHeaders ?? {},
        timeout: timeout ?? _defaultTimeout,
        isActive: true,
        registeredAt: DateTime.now(),
        lastUsed: null,
        totalRequests: 0,
        successfulRequests: 0,
        failedRequests: 0,
      );

      _integratedApis[apiId] = api;

      // Настраиваем лимиты скорости
      if (rateLimitPerMinute != null) {
        _rateLimits[apiId] = ApiRateLimit(
          apiId: apiId,
          requestsPerMinute: rateLimitPerMinute,
          requestsInCurrentMinute: 0,
          lastResetTime: DateTime.now(),
          isBlocked: false,
        );
      }

      // Тестируем подключение
      final testResult = await _testApiConnection(api);
      if (!testResult.success) {
        api.isActive = false;
        return ApiRegistrationResult(
          apiId: apiId,
          success: false,
          errorMessage: testResult.errorMessage,
        );
      }

      return ApiRegistrationResult(
        apiId: apiId,
        success: true,
      );
    } catch (e) {
      return ApiRegistrationResult(
        apiId: apiId,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Выполнение запроса к внешнему API
  Future<ApiResponse> makeRequest({
    required String apiId,
    required String endpoint,
    HttpMethod method = HttpMethod.get,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool useCache = false,
  }) async {
    final api = _integratedApis[apiId];
    if (api == null) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        data: null,
        errorMessage: 'API not found: $apiId',
        responseTime: Duration.zero,
        cached: false,
      );
    }

    if (!api.isActive) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        data: null,
        errorMessage: 'API is not active: $apiId',
        responseTime: Duration.zero,
        cached: false,
      );
    }

    // Проверяем кэш
    if (useCache) {
      final cacheKey = _generateCacheKey(apiId, endpoint, method, queryParameters);
      final cachedResponse = _getCachedResponse(cacheKey);
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    // Проверяем лимиты скорости
    if (!_checkRateLimit(apiId)) {
      return ApiResponse(
        success: false,
        statusCode: 429,
        data: null,
        errorMessage: 'Rate limit exceeded for API: $apiId',
        responseTime: Duration.zero,
        cached: false,
      );
    }

    try {
      final startTime = DateTime.now();
      final response = await _executeHttpRequest(api, endpoint, method, headers, body, queryParameters);
      final responseTime = DateTime.now().difference(startTime);

      // Обновляем статистику
      api.totalRequests++;
      api.lastUsed = DateTime.now();

      final apiResponse = ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        statusCode: response.statusCode,
        data: response.success ? _parseResponseData(response.body) : null,
        errorMessage: response.success ? null : response.errorMessage,
        responseTime: responseTime,
        cached: false,
      );

      if (response.success) {
        api.successfulRequests++;
      } else {
        api.failedRequests++;
      }

      // Кэшируем успешные ответы
      if (useCache && response.success) {
        final cacheKey = _generateCacheKey(apiId, endpoint, method, queryParameters);
        _cacheResponse(cacheKey, apiResponse);
      }

      return apiResponse;
    } catch (e) {
      api.failedRequests++;
      return ApiResponse(
        success: false,
        statusCode: 0,
        data: null,
        errorMessage: e.toString(),
        responseTime: Duration.zero,
        cached: false,
      );
    }
  }

  /// Получение списка зарегистрированных API
  List<ExternalApi> getRegisteredApis() {
    return _integratedApis.values.toList();
  }

  /// Получение статистики API
  Future<ApiStatistics> getApiStatistics(String apiId) async {
    final api = _integratedApis[apiId];
    if (api == null) {
      throw Exception('API not found: $apiId');
    }

    final rateLimit = _rateLimits[apiId];
    final uptime = api.lastUsed != null ? DateTime.now().difference(api.registeredAt) : Duration.zero;

    return ApiStatistics(
      apiId: apiId,
      totalRequests: api.totalRequests,
      successfulRequests: api.successfulRequests,
      failedRequests: api.failedRequests,
      successRate: api.totalRequests > 0 ? api.successfulRequests / api.totalRequests : 0.0,
      uptime: uptime,
      isActive: api.isActive,
      rateLimit: rateLimit,
      averageResponseTime: _calculateAverageResponseTime(apiId),
      lastUsed: api.lastUsed,
    );
  }

  /// Деактивация API
  Future<bool> deactivateApi(String apiId) async {
    final api = _integratedApis[apiId];
    if (api == null) {
      return false;
    }

    api.isActive = false;
    return true;
  }

  /// Реактивация API
  Future<bool> reactivateApi(String apiId) async {
    final api = _integratedApis[apiId];
    if (api == null) {
      return false;
    }

    // Тестируем подключение перед реактивацией
    final testResult = await _testApiConnection(api);
    if (testResult.success) {
      api.isActive = true;
      return true;
    }

    return false;
  }

  /// Получение данных из кэша
  ApiResponse? getCachedResponse({
    required String apiId,
    required String endpoint,
    HttpMethod method = HttpMethod.get,
    Map<String, String>? queryParameters,
  }) {
    final cacheKey = _generateCacheKey(apiId, endpoint, method, queryParameters);
    return _getCachedResponse(cacheKey);
  }

  /// Очистка кэша
  void clearCache({String? apiId}) {
    if (apiId != null) {
      _apiCache.removeWhere((key, cache) => key.startsWith(apiId));
    } else {
      _apiCache.clear();
    }
  }

  /// Загрузка конфигураций API
  Future<void> _loadApiConfigurations() async {
    // В реальной реализации здесь будет загрузка из конфигурационных файлов
    // Для демонстрации создаем несколько тестовых API
    await _createDefaultApis();
  }

  /// Создание API по умолчанию
  Future<void> _createDefaultApis() async {
    // OpenAI API
    await registerApi(
      apiId: 'openai',
      name: 'OpenAI API',
      baseUrl: 'https://api.openai.com/v1',
      authentication: ApiAuthentication.bearer(token: 'your-openai-token'),
      rateLimitPerMinute: 60,
    );

    // GitHub API
    await registerApi(
      apiId: 'github',
      name: 'GitHub API',
      baseUrl: 'https://api.github.com',
      authentication: ApiAuthentication.bearer(token: 'your-github-token'),
      rateLimitPerMinute: 5000,
    );

    // Weather API
    await registerApi(
      apiId: 'weather',
      name: 'OpenWeatherMap API',
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      authentication: ApiAuthentication.apiKey(key: 'your-weather-api-key'),
      rateLimitPerMinute: 1000,
    );
  }

  /// Настройка мониторинга лимитов скорости
  void _setupRateLimitMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _resetRateLimits();
    });
  }

  /// Настройка очистки кэша
  void _setupCacheCleanup() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _cleanupExpiredCache();
    });
  }

  /// Тестирование подключения к API
  Future<ApiTestResult> _testApiConnection(ExternalApi api) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('${api.baseUrl}/'),
            headers: _buildHeaders(api, {}),
          )
          .timeout(api.timeout);

      return ApiTestResult(
        success: response.statusCode < 500,
        statusCode: response.statusCode,
        errorMessage: response.statusCode >= 400 ? response.body : null,
      );
    } catch (e) {
      return ApiTestResult(
        success: false,
        statusCode: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Проверка лимитов скорости
  bool _checkRateLimit(String apiId) {
    final rateLimit = _rateLimits[apiId];
    if (rateLimit == null) return true;

    if (rateLimit.isBlocked) {
      final timeSinceReset = DateTime.now().difference(rateLimit.lastResetTime);
      if (timeSinceReset.inMinutes >= 1) {
        rateLimit.isBlocked = false;
        rateLimit.requestsInCurrentMinute = 0;
        rateLimit.lastResetTime = DateTime.now();
      } else {
        return false;
      }
    }

    if (rateLimit.requestsInCurrentMinute >= rateLimit.requestsPerMinute) {
      rateLimit.isBlocked = true;
      return false;
    }

    rateLimit.requestsInCurrentMinute++;
    return true;
  }

  /// Выполнение HTTP запроса
  Future<HttpResponse> _executeHttpRequest(
    ExternalApi api,
    String endpoint,
    HttpMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  ) async {
    final uri = _buildUri(api.baseUrl, endpoint, queryParameters);
    final requestHeaders = _buildHeaders(api, headers ?? {});

    http.Response response;
    switch (method) {
      case HttpMethod.get:
        response = await _httpClient.get(uri, headers: requestHeaders).timeout(api.timeout);
      case HttpMethod.post:
        response = await _httpClient
            .post(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null)
            .timeout(api.timeout);
      case HttpMethod.put:
        response = await _httpClient
            .put(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null)
            .timeout(api.timeout);
      case HttpMethod.delete:
        response = await _httpClient.delete(uri, headers: requestHeaders).timeout(api.timeout);
      case HttpMethod.patch:
        response = await _httpClient
            .patch(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null)
            .timeout(api.timeout);
    }

    return HttpResponse(
      success: response.statusCode >= 200 && response.statusCode < 300,
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
      errorMessage: response.statusCode >= 400 ? response.body : null,
    );
  }

  /// Построение URI
  Uri _buildUri(String baseUrl, String endpoint, Map<String, String>? queryParameters) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
  }

  /// Построение заголовков
  Map<String, String> _buildHeaders(ExternalApi api, Map<String, String> additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent': 'Katya-ExternalAPI/1.0',
      ...api.defaultHeaders,
      ...additionalHeaders,
    };

    // Добавляем аутентификацию
    switch (api.authentication.type) {
      case AuthenticationType.bearer:
        headers['Authorization'] = 'Bearer ${api.authentication.token}';
      case AuthenticationType.apiKey:
        headers[api.authentication.headerName] = api.authentication.apiKey;
      case AuthenticationType.basic:
        final credentials = base64Encode(utf8.encode('${api.authentication.username}:${api.authentication.password}'));
        headers['Authorization'] = 'Basic $credentials';
      case AuthenticationType.none:
        break;
    }

    return headers;
  }

  /// Парсинг данных ответа
  dynamic _parseResponseData(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      return responseBody;
    }
  }

  /// Генерация ключа кэша
  String _generateCacheKey(
    String apiId,
    String endpoint,
    HttpMethod method,
    Map<String, String>? queryParameters,
  ) {
    final queryString = queryParameters != null && queryParameters.isNotEmpty
        ? queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';
    return '${apiId}_${method.name}_$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  /// Получение кэшированного ответа
  ApiResponse? _getCachedResponse(String cacheKey) {
    final cache = _apiCache[cacheKey];
    if (cache == null) return null;

    final now = DateTime.now();
    if (now.difference(cache.cachedAt).compareTo(_cacheTimeout) > 0) {
      _apiCache.remove(cacheKey);
      return null;
    }

    return cache.response;
  }

  /// Кэширование ответа
  void _cacheResponse(String cacheKey, ApiResponse response) {
    if (_apiCache.length >= _maxCacheSize) {
      // Удаляем самые старые записи
      final oldestKey = _apiCache.entries.reduce((a, b) => a.value.cachedAt.isBefore(b.value.cachedAt) ? a : b).key;
      _apiCache.remove(oldestKey);
    }

    _apiCache[cacheKey] = ApiCache(
      cacheKey: cacheKey,
      response: response,
      cachedAt: DateTime.now(),
    );
  }

  /// Сброс лимитов скорости
  Future<void> _resetRateLimits() async {
    final now = DateTime.now();
    for (final rateLimit in _rateLimits.values) {
      if (now.difference(rateLimit.lastResetTime).inMinutes >= 1) {
        rateLimit.requestsInCurrentMinute = 0;
        rateLimit.lastResetTime = now;
        rateLimit.isBlocked = false;
      }
    }
  }

  /// Очистка истекшего кэша
  Future<void> _cleanupExpiredCache() async {
    final now = DateTime.now();
    _apiCache.removeWhere((key, cache) => now.difference(cache.cachedAt).compareTo(_cacheTimeout) > 0);
  }

  /// Расчет среднего времени ответа
  Duration _calculateAverageResponseTime(String apiId) {
    // В реальной реализации здесь будет расчет на основе исторических данных
    return const Duration(milliseconds: 500); // Заглушка
  }

  /// Освобождение ресурсов
  void dispose() {
    _httpClient.close();
    _integratedApis.clear();
    _rateLimits.clear();
    _apiCache.clear();
  }
}

/// Внешний API
class ExternalApi extends Equatable {
  final String apiId;
  final String name;
  final String baseUrl;
  final ApiAuthentication authentication;
  final Map<String, String> defaultHeaders;
  final Duration timeout;
  bool isActive;
  final DateTime registeredAt;
  DateTime? lastUsed;
  int totalRequests;
  int successfulRequests;
  int failedRequests;

  ExternalApi({
    required this.apiId,
    required this.name,
    required this.baseUrl,
    required this.authentication,
    required this.defaultHeaders,
    required this.timeout,
    required this.isActive,
    required this.registeredAt,
    this.lastUsed,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
  });

  @override
  List<Object?> get props => [
        apiId,
        name,
        baseUrl,
        authentication,
        defaultHeaders,
        timeout,
        isActive,
        registeredAt,
        lastUsed,
        totalRequests,
        successfulRequests,
        failedRequests,
      ];
}

/// Аутентификация API
class ApiAuthentication extends Equatable {
  final AuthenticationType type;
  final String? token;
  final String? apiKey;
  final String? headerName;
  final String? username;
  final String? password;

  const ApiAuthentication({
    required this.type,
    this.token,
    this.apiKey,
    this.headerName,
    this.username,
    this.password,
  });

  factory ApiAuthentication.bearer({required String token}) {
    return ApiAuthentication(type: AuthenticationType.bearer, token: token);
  }

  factory ApiAuthentication.apiKey({required String key, String headerName = 'X-API-Key'}) {
    return ApiAuthentication(type: AuthenticationType.apiKey, apiKey: key, headerName: headerName);
  }

  factory ApiAuthentication.basic({required String username, required String password}) {
    return ApiAuthentication(type: AuthenticationType.basic, username: username, password: password);
  }

  factory ApiAuthentication.none() {
    return const ApiAuthentication(type: AuthenticationType.none);
  }

  @override
  List<Object?> get props => [type, token, apiKey, headerName, username, password];
}

/// Типы аутентификации
enum AuthenticationType {
  bearer,
  apiKey,
  basic,
  none,
}

/// HTTP методы
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
}

/// Результат регистрации API
class ApiRegistrationResult extends Equatable {
  final String apiId;
  final bool success;
  final String? errorMessage;

  const ApiRegistrationResult({
    required this.apiId,
    required this.success,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [apiId, success, errorMessage];
}

/// Ответ API
class ApiResponse extends Equatable {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? errorMessage;
  final Duration responseTime;
  final bool cached;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.data,
    this.errorMessage,
    required this.responseTime,
    required this.cached,
  });

  @override
  List<Object?> get props => [success, statusCode, data, errorMessage, responseTime, cached];
}

/// HTTP ответ
class HttpResponse extends Equatable {
  final bool success;
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final String? errorMessage;

  const HttpResponse({
    required this.success,
    required this.statusCode,
    required this.body,
    required this.headers,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, statusCode, body, headers, errorMessage];
}

/// Лимит скорости API
class ApiRateLimit extends Equatable {
  final String apiId;
  final int requestsPerMinute;
  int requestsInCurrentMinute;
  DateTime lastResetTime;
  bool isBlocked;

  ApiRateLimit({
    required this.apiId,
    required this.requestsPerMinute,
    required this.requestsInCurrentMinute,
    required this.lastResetTime,
    required this.isBlocked,
  });

  @override
  List<Object?> get props => [apiId, requestsPerMinute, requestsInCurrentMinute, lastResetTime, isBlocked];
}

/// Кэш API
class ApiCache extends Equatable {
  final String cacheKey;
  final ApiResponse response;
  final DateTime cachedAt;

  const ApiCache({
    required this.cacheKey,
    required this.response,
    required this.cachedAt,
  });

  @override
  List<Object?> get props => [cacheKey, response, cachedAt];
}

/// Статистика API
class ApiStatistics extends Equatable {
  final String apiId;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double successRate;
  final Duration uptime;
  final bool isActive;
  final ApiRateLimit? rateLimit;
  final Duration averageResponseTime;
  final DateTime? lastUsed;

  const ApiStatistics({
    required this.apiId,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.successRate,
    required this.uptime,
    required this.isActive,
    this.rateLimit,
    required this.averageResponseTime,
    this.lastUsed,
  });

  @override
  List<Object?> get props => [
        apiId,
        totalRequests,
        successfulRequests,
        failedRequests,
        successRate,
        uptime,
        isActive,
        rateLimit,
        averageResponseTime,
        lastUsed,
      ];
}

/// Результат тестирования API
class ApiTestResult extends Equatable {
  final bool success;
  final int statusCode;
  final String? errorMessage;

  const ApiTestResult({
    required this.success,
    required this.statusCode,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [success, statusCode, errorMessage];
}
