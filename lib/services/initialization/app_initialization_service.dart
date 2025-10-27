import 'dart:async';

import 'package:katya/services/analytics/network_analytics_service.dart';
import 'package:katya/services/anonymous/anonymous_messaging_service.dart';
import 'package:katya/services/backup/backup_service.dart';
import 'package:katya/services/blockchain/blockchain_verification_service.dart';
import 'package:katya/services/cloud/cloud_sync_service.dart';
import 'package:katya/services/consensus/consensus_voting_service.dart';
import 'package:katya/services/data_export/data_export_service.dart';
import 'package:katya/services/data_export_import/bulk_operations_service.dart';
import 'package:katya/services/data_export_import/data_validation_service.dart';
import 'package:katya/services/data_import/data_import_service.dart';
import 'package:katya/services/external/external_api_integration_service.dart';
import 'package:katya/services/i18n/internationalization_service.dart';
import 'package:katya/services/i18n/regional_settings_service.dart';
import 'package:katya/services/iot/iot_integration_service.dart';
import 'package:katya/services/ml/machine_learning_service.dart';
import 'package:katya/services/mobile/mobile_integration_service.dart';
import 'package:katya/services/performance/cache_service.dart';
import 'package:katya/services/performance/performance_monitoring_service.dart';
import 'package:katya/services/performance/performance_optimization_service.dart' as perf_opt;
import 'package:katya/services/performance_analytics/performance_metrics_service.dart';
import 'package:katya/services/performance_analytics/performance_optimization_service.dart';
import 'package:katya/services/performance_analytics/performance_profiler_service.dart';
import 'package:katya/services/performance_analytics/performance_trend_analyzer_service.dart';
import 'package:katya/services/security/advanced_security_service.dart';
import 'package:katya/services/trust_network/reputation/reputation_service.dart';
import 'package:katya/services/trust_network/trust_network_service.dart';
import 'package:katya/services/trust_network/trust_verification_service.dart';

/// Сервис для инициализации всех компонентов приложения
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();

  bool _isInitialized = false;
  final List<String> _initializationErrors = [];
  final List<String> _initializationWarnings = [];

  factory AppInitializationService() => _instance;

  AppInitializationService._internal();

  /// Инициализация всех сервисов приложения
  Future<void> initializeApp() async {
    if (_isInitialized) {
      print('App already initialized');
      return;
    }

    print('Starting app initialization...');
    final stopwatch = Stopwatch()..start();

    try {
      // Инициализация основных сервисов
      await _initializeCoreServices();

      // Инициализация сервисов производительности
      await _initializePerformanceServices();

      // Инициализация сервисов интернационализации
      await _initializeI18nServices();

      // Инициализация сервисов управления данными
      await _initializeDataManagementServices();

      // Инициализация сервисов резервного копирования
      await _initializeBackupServices();

      // Инициализация сервисов доверительной сети
      await _initializeTrustNetworkServices();

      // Инициализация дополнительных сервисов
      await _initializeAdditionalServices();

      _isInitialized = true;
      stopwatch.stop();

      print('App initialization completed successfully in ${stopwatch.elapsedMilliseconds}ms');

      if (_initializationWarnings.isNotEmpty) {
        print('Initialization warnings: ${_initializationWarnings.join(', ')}');
      }
    } catch (e) {
      stopwatch.stop();
      _initializationErrors.add('Initialization failed: $e');
      print('App initialization failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Инициализация основных сервисов
  Future<void> _initializeCoreServices() async {
    print('Initializing core services...');

    try {
      // Инициализация сервиса кэширования
      await CacheService().initialize();
      print('✓ Cache service initialized');

      // Инициализация сервиса мониторинга производительности
      await PerformanceMonitoringService().initialize();
      print('✓ Performance monitoring service initialized');

      // Инициализация сервиса оптимизации производительности
      await perf_opt.PerformanceOptimizationService().initialize();
      print('✓ Performance optimization service initialized');
    } catch (e) {
      _initializationErrors.add('Core services initialization failed: $e');
      print('✗ Core services initialization failed: $e');
    }
  }

  /// Инициализация сервисов производительности
  Future<void> _initializePerformanceServices() async {
    print('Initializing performance services...');

    try {
      // Инициализация сервиса метрик производительности
      PerformanceMetricsService();
      print('✓ Performance metrics service initialized');

      // Инициализация сервиса профилирования
      PerformanceProfilerService();
      print('✓ Performance profiler service initialized');

      // Инициализация сервиса оптимизации
      PerformanceOptimizationService();
      print('✓ Performance optimization service initialized');

      // Инициализация сервиса анализа трендов
      PerformanceTrendAnalyzerService();
      print('✓ Performance trend analyzer service initialized');
    } catch (e) {
      _initializationErrors.add('Performance services initialization failed: $e');
      print('✗ Performance services initialization failed: $e');
    }
  }

  /// Инициализация сервисов интернационализации
  Future<void> _initializeI18nServices() async {
    print('Initializing i18n services...');

    try {
      // Инициализация сервиса интернационализации
      await InternationalizationService().initialize();
      print('✓ Internationalization service initialized');

      // Инициализация сервиса региональных настроек
      RegionalSettingsService().initialize();
      print('✓ Regional settings service initialized');
    } catch (e) {
      _initializationWarnings.add('I18n services initialization failed: $e');
      print('⚠ I18n services initialization failed: $e');
    }
  }

  /// Инициализация сервисов управления данными
  Future<void> _initializeDataManagementServices() async {
    print('Initializing data management services...');

    try {
      // Инициализация сервиса экспорта данных
      DataExportService();
      print('✓ Data export service initialized');

      // Инициализация сервиса импорта данных
      DataImportService();
      print('✓ Data import service initialized');

      // Инициализация сервиса массовых операций
      BulkOperationsService();
      print('✓ Bulk operations service initialized');

      // Инициализация сервиса валидации данных
      DataValidationService();
      print('✓ Data validation service initialized');
    } catch (e) {
      _initializationWarnings.add('Data management services initialization failed: $e');
      print('⚠ Data management services initialization failed: $e');
    }
  }

  /// Инициализация сервисов резервного копирования
  Future<void> _initializeBackupServices() async {
    print('Initializing backup services...');

    try {
      // Инициализация сервиса резервного копирования
      BackupService();
      print('✓ Backup service initialized');
    } catch (e) {
      _initializationWarnings.add('Backup services initialization failed: $e');
      print('⚠ Backup services initialization failed: $e');
    }
  }

  /// Инициализация сервисов доверительной сети
  Future<void> _initializeTrustNetworkServices() async {
    print('Initializing trust network services...');

    try {
      // Инициализация сервиса доверительной сети
      TrustNetworkService();
      print('✓ Trust network service initialized');

      // Инициализация сервиса верификации доверия
      TrustVerificationService();
      print('✓ Trust verification service initialized');

      // Инициализация сервиса репутации
      ReputationService();
      print('✓ Reputation service initialized');

      // Инициализация сервиса блокчейн верификации
      BlockchainVerificationService();
      print('✓ Blockchain verification service initialized');

      // Инициализация сервиса анонимных сообщений
      AnonymousMessagingService();
      print('✓ Anonymous messaging service initialized');

      // Инициализация сервиса IoT интеграции
      IoTIntegrationService();
      print('✓ IoT integration service initialized');

      // Инициализация сервиса консенсуса
      ConsensusVotingService();
      print('✓ Consensus voting service initialized');

      // Инициализация сервиса сетевой аналитики
      NetworkAnalyticsService();
      print('✓ Network analytics service initialized');
    } catch (e) {
      _initializationWarnings.add('Trust network services initialization failed: $e');
      print('⚠ Trust network services initialization failed: $e');
    }
  }

  /// Инициализация дополнительных сервисов
  Future<void> _initializeAdditionalServices() async {
    print('Initializing additional services...');

    try {
      // Инициализация сервиса внешних API
      ExternalApiIntegrationService();
      print('✓ External API integration service initialized');

      // Инициализация сервиса машинного обучения
      MachineLearningService();
      print('✓ Machine learning service initialized');

      // Инициализация сервиса продвинутой безопасности
      AdvancedSecurityService();
      print('✓ Advanced security service initialized');

      // Инициализация сервиса мобильной интеграции
      MobileIntegrationService();
      print('✓ Mobile integration service initialized');

      // Инициализация сервиса облачной синхронизации
      CloudSyncService();
      print('✓ Cloud sync service initialized');
    } catch (e) {
      _initializationWarnings.add('Additional services initialization failed: $e');
      print('⚠ Additional services initialization failed: $e');
    }
  }

  /// Проверка статуса инициализации
  bool get isInitialized => _isInitialized;

  /// Получение ошибок инициализации
  List<String> get initializationErrors => List<String>.from(_initializationErrors);

  /// Получение предупреждений инициализации
  List<String> get initializationWarnings => List<String>.from(_initializationWarnings);

  /// Получение статуса инициализации
  Map<String, dynamic> getInitializationStatus() {
    return {
      'isInitialized': _isInitialized,
      'errors': _initializationErrors,
      'warnings': _initializationWarnings,
      'errorCount': _initializationErrors.length,
      'warningCount': _initializationWarnings.length,
    };
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    if (!_isInitialized) return;

    print('Disposing app services...');

    try {
      // Остановка сервисов производительности
      PerformanceMetricsService().dispose();
      PerformanceProfilerService().dispose();
      PerformanceOptimizationService().dispose();
      PerformanceTrendAnalyzerService().dispose();

      // Остановка других сервисов
      CacheService().dispose();
      PerformanceMonitoringService().dispose();
      perf_opt.PerformanceOptimizationService().dispose();

      _isInitialized = false;
      _initializationErrors.clear();
      _initializationWarnings.clear();

      print('App services disposed successfully');
    } catch (e) {
      print('Error disposing app services: $e');
    }
  }
}
