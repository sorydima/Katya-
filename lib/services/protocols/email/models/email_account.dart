import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/services/protocols/email/models/pgp_key.dart';

part 'email_account.g.dart';

/// Модель E-Mail аккаунта
@JsonSerializable()
class EmailAccount extends Equatable {
  /// E-Mail адрес
  final String email;

  /// Имя пользователя
  final String username;

  /// Пароль
  @JsonKey(ignore: true)
  final String password;

  /// Отображаемое имя
  final String displayName;

  /// SMTP настройки
  final SMTPSettings smtpSettings;

  /// IMAP настройки
  final IMAPSettings imapSettings;

  /// POP3 настройки
  final POP3Settings? pop3Settings;

  /// PGP настройки
  final PGPSettings pgpSettings;

  /// Статус аккаунта
  final AccountStatus status;

  /// Время последней синхронизации
  final DateTime? lastSync;

  /// Время создания аккаунта
  final DateTime createdAt;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const EmailAccount({
    required this.email,
    required this.username,
    required this.password,
    required this.displayName,
    required this.smtpSettings,
    required this.imapSettings,
    this.pop3Settings,
    this.pgpSettings = const PGPSettings(),
    this.status = AccountStatus.inactive,
    this.lastSync,
    required this.createdAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        email,
        username,
        displayName,
        smtpSettings,
        imapSettings,
        pop3Settings,
        pgpSettings,
        status,
        lastSync,
        createdAt,
        metadata,
      ];

  EmailAccount copyWith({
    String? email,
    String? username,
    String? password,
    String? displayName,
    SMTPSettings? smtpSettings,
    IMAPSettings? imapSettings,
    POP3Settings? pop3Settings,
    PGPSettings? pgpSettings,
    AccountStatus? status,
    DateTime? lastSync,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return EmailAccount(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      smtpSettings: smtpSettings ?? this.smtpSettings,
      imapSettings: imapSettings ?? this.imapSettings,
      pop3Settings: pop3Settings ?? this.pop3Settings,
      pgpSettings: pgpSettings ?? this.pgpSettings,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Получение SMTP хоста
  String get smtpHost => smtpSettings.host;

  /// Получение SMTP порта
  int get smtpPort => smtpSettings.port;

  /// Проверка использования SSL для SMTP
  bool get smtpUseSSL => smtpSettings.useSSL;

  /// Проверка использования STARTTLS для SMTP
  bool get smtpUseSTARTTLS => smtpSettings.useSTARTTLS;

  /// Получение IMAP хоста
  String get imapHost => imapSettings.host;

  /// Получение IMAP порта
  int get imapPort => imapSettings.port;

  /// Проверка использования SSL для IMAP
  bool get imapUseSSL => imapSettings.useSSL;

  /// Проверка использования STARTTLS для IMAP
  bool get imapUseSTARTTLS => imapSettings.useSTARTTLS;

  /// Проверка, включен ли PGP
  bool get pgpEnabled => pgpSettings.enabled;

  /// Проверка, активен ли аккаунт
  bool get isActive => status == AccountStatus.active;

  /// Проверка, настроен ли аккаунт
  bool get isConfigured => status != AccountStatus.notConfigured;

  /// Получение домена email
  String get domain => email.split('@').last;

  /// Получение локальной части email
  String get localPart => email.split('@').first;

  Map<String, dynamic> toJson() => _$EmailAccountToJson(this);
  factory EmailAccount.fromJson(Map<String, dynamic> json) => _$EmailAccountFromJson(json);
}

/// Статус аккаунта
enum AccountStatus {
  @JsonValue('not_configured')
  notConfigured,
  @JsonValue('inactive')
  inactive,
  @JsonValue('active')
  active,
  @JsonValue('error')
  error,
  @JsonValue('suspended')
  suspended,
}

/// SMTP настройки
@JsonSerializable()
class SMTPSettings extends Equatable {
  /// Хост SMTP сервера
  final String host;

  /// Порт SMTP сервера
  final int port;

  /// Использовать SSL
  final bool useSSL;

  /// Использовать STARTTLS
  final bool useSTARTTLS;

  /// Требуется аутентификация
  final bool requireAuth;

  /// Таймаут подключения
  final int connectionTimeout;

  /// Таймаут отправки
  final int sendTimeout;

  /// Максимальный размер сообщения
  final int maxMessageSize;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  const SMTPSettings({
    required this.host,
    required this.port,
    this.useSSL = false,
    this.useSTARTTLS = true,
    this.requireAuth = true,
    this.connectionTimeout = 30000,
    this.sendTimeout = 60000,
    this.maxMessageSize = 25 * 1024 * 1024, // 25MB
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        host,
        port,
        useSSL,
        useSTARTTLS,
        requireAuth,
        connectionTimeout,
        sendTimeout,
        maxMessageSize,
        parameters,
      ];

  SMTPSettings copyWith({
    String? host,
    int? port,
    bool? useSSL,
    bool? useSTARTTLS,
    bool? requireAuth,
    int? connectionTimeout,
    int? sendTimeout,
    int? maxMessageSize,
    Map<String, dynamic>? parameters,
  }) {
    return SMTPSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      useSSL: useSSL ?? this.useSSL,
      useSTARTTLS: useSTARTTLS ?? this.useSTARTTLS,
      requireAuth: requireAuth ?? this.requireAuth,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      maxMessageSize: maxMessageSize ?? this.maxMessageSize,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => _$SMTPSettingsToJson(this);
  factory SMTPSettings.fromJson(Map<String, dynamic> json) => _$SMTPSettingsFromJson(json);
}

/// IMAP настройки
@JsonSerializable()
class IMAPSettings extends Equatable {
  /// Хост IMAP сервера
  final String host;

  /// Порт IMAP сервера
  final int port;

  /// Использовать SSL
  final bool useSSL;

  /// Использовать STARTTLS
  final bool useSTARTTLS;

  /// Таймаут подключения
  final int connectionTimeout;

  /// Таймаут чтения
  final int readTimeout;

  /// Автоматически подписываться на новые папки
  final bool autoSubscribe;

  /// Использовать IDLE для уведомлений
  final bool useIdle;

  /// Максимальное количество сообщений для загрузки
  final int maxMessages;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  const IMAPSettings({
    required this.host,
    required this.port,
    this.useSSL = true,
    this.useSTARTTLS = false,
    this.connectionTimeout = 30000,
    this.readTimeout = 10000,
    this.autoSubscribe = true,
    this.useIdle = true,
    this.maxMessages = 1000,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        host,
        port,
        useSSL,
        useSTARTTLS,
        connectionTimeout,
        readTimeout,
        autoSubscribe,
        useIdle,
        maxMessages,
        parameters,
      ];

  IMAPSettings copyWith({
    String? host,
    int? port,
    bool? useSSL,
    bool? useSTARTTLS,
    int? connectionTimeout,
    int? readTimeout,
    bool? autoSubscribe,
    bool? useIdle,
    int? maxMessages,
    Map<String, dynamic>? parameters,
  }) {
    return IMAPSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      useSSL: useSSL ?? this.useSSL,
      useSTARTTLS: useSTARTTLS ?? this.useSTARTTLS,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      readTimeout: readTimeout ?? this.readTimeout,
      autoSubscribe: autoSubscribe ?? this.autoSubscribe,
      useIdle: useIdle ?? this.useIdle,
      maxMessages: maxMessages ?? this.maxMessages,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => _$IMAPSettingsToJson(this);
  factory IMAPSettings.fromJson(Map<String, dynamic> json) => _$IMAPSettingsFromJson(json);
}

/// POP3 настройки
@JsonSerializable()
class POP3Settings extends Equatable {
  /// Хост POP3 сервера
  final String host;

  /// Порт POP3 сервера
  final int port;

  /// Использовать SSL
  final bool useSSL;

  /// Использовать STARTTLS
  final bool useSTARTTLS;

  /// Таймаут подключения
  final int connectionTimeout;

  /// Таймаут чтения
  final int readTimeout;

  /// Удалять сообщения после загрузки
  final bool deleteAfterDownload;

  /// Максимальное количество сообщений для загрузки
  final int maxMessages;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  const POP3Settings({
    required this.host,
    required this.port,
    this.useSSL = true,
    this.useSTARTTLS = false,
    this.connectionTimeout = 30000,
    this.readTimeout = 10000,
    this.deleteAfterDownload = false,
    this.maxMessages = 100,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        host,
        port,
        useSSL,
        useSTARTTLS,
        connectionTimeout,
        readTimeout,
        deleteAfterDownload,
        maxMessages,
        parameters,
      ];

  POP3Settings copyWith({
    String? host,
    int? port,
    bool? useSSL,
    bool? useSTARTTLS,
    int? connectionTimeout,
    int? readTimeout,
    bool? deleteAfterDownload,
    int? maxMessages,
    Map<String, dynamic>? parameters,
  }) {
    return POP3Settings(
      host: host ?? this.host,
      port: port ?? this.port,
      useSSL: useSSL ?? this.useSSL,
      useSTARTTLS: useSTARTTLS ?? this.useSTARTTLS,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      readTimeout: readTimeout ?? this.readTimeout,
      deleteAfterDownload: deleteAfterDownload ?? this.deleteAfterDownload,
      maxMessages: maxMessages ?? this.maxMessages,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => _$POP3SettingsToJson(this);
  factory POP3Settings.fromJson(Map<String, dynamic> json) => _$POP3SettingsFromJson(json);
}

/// PGP настройки
@JsonSerializable()
class PGPSettings extends Equatable {
  /// Включен ли PGP
  final bool enabled;

  /// Автоматически шифровать исходящие сообщения
  final bool autoEncrypt;

  /// Автоматически подписывать исходящие сообщения
  final bool autoSign;

  /// Проверять подписи входящих сообщений
  final bool verifySignatures;

  /// Расшифровывать входящие сообщения
  final bool autoDecrypt;

  /// Публичный ключ
  @JsonKey(ignore: true)
  final PGPKey? publicKey;

  /// Приватный ключ
  @JsonKey(ignore: true)
  final PGPKey? privateKey;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  const PGPSettings({
    this.enabled = false,
    this.autoEncrypt = false,
    this.autoSign = false,
    this.verifySignatures = true,
    this.autoDecrypt = true,
    this.publicKey,
    this.privateKey,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        enabled,
        autoEncrypt,
        autoSign,
        verifySignatures,
        autoDecrypt,
        publicKey,
        privateKey,
        parameters,
      ];

  PGPSettings copyWith({
    bool? enabled,
    bool? autoEncrypt,
    bool? autoSign,
    bool? verifySignatures,
    bool? autoDecrypt,
    PGPKey? publicKey,
    PGPKey? privateKey,
    Map<String, dynamic>? parameters,
  }) {
    return PGPSettings(
      enabled: enabled ?? this.enabled,
      autoEncrypt: autoEncrypt ?? this.autoEncrypt,
      autoSign: autoSign ?? this.autoSign,
      verifySignatures: verifySignatures ?? this.verifySignatures,
      autoDecrypt: autoDecrypt ?? this.autoDecrypt,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      parameters: parameters ?? this.parameters,
    );
  }

  /// Проверка, настроен ли PGP
  bool get isConfigured => publicKey != null && privateKey != null;

  Map<String, dynamic> toJson() => _$PGPSettingsToJson(this);
  factory PGPSettings.fromJson(Map<String, dynamic> json) => _$PGPSettingsFromJson(json);
}
