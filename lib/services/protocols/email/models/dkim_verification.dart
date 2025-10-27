import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dkim_verification.g.dart';

/// Результат верификации DKIM
@JsonSerializable()
class DKIMVerificationResult extends Equatable {
  /// Успешна ли верификация
  final bool isVerified;

  /// Домен отправителя
  final String? domain;

  /// Селектор DKIM
  final String? selector;

  /// Алгоритм подписи
  final String? algorithm;

  /// Отпечаток ключа
  final String? keyFingerprint;

  /// Время верификации
  final DateTime? verifiedAt;

  /// Сообщение об ошибке
  final String? error;

  /// Дополнительные детали
  final Map<String, dynamic> details;

  const DKIMVerificationResult({
    required this.isVerified,
    this.domain,
    this.selector,
    this.algorithm,
    this.keyFingerprint,
    this.verifiedAt,
    this.error,
    this.details = const {},
  });

  @override
  List<Object?> get props => [
        isVerified,
        domain,
        selector,
        algorithm,
        keyFingerprint,
        verifiedAt,
        error,
        details,
      ];

  DKIMVerificationResult copyWith({
    bool? isVerified,
    String? domain,
    String? selector,
    String? algorithm,
    String? keyFingerprint,
    DateTime? verifiedAt,
    String? error,
    Map<String, dynamic>? details,
  }) {
    return DKIMVerificationResult(
      isVerified: isVerified ?? this.isVerified,
      domain: domain ?? this.domain,
      selector: selector ?? this.selector,
      algorithm: algorithm ?? this.algorithm,
      keyFingerprint: keyFingerprint ?? this.keyFingerprint,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() => _$DKIMVerificationResultToJson(this);
  factory DKIMVerificationResult.fromJson(Map<String, dynamic> json) => _$DKIMVerificationResultFromJson(json);
}

/// Результат верификации SPF
@JsonSerializable()
class SPFVerificationResult extends Equatable {
  /// Результат проверки SPF
  final SPFResult result;

  /// Домен отправителя
  final String? domain;

  /// IP адрес отправителя
  final String? ipAddress;

  /// SPF запись
  final String? spfRecord;

  /// Время верификации
  final DateTime? verifiedAt;

  /// Сообщение об ошибке
  final String? error;

  /// Дополнительные детали
  final Map<String, dynamic> details;

  const SPFVerificationResult({
    required this.result,
    this.domain,
    this.ipAddress,
    this.spfRecord,
    this.verifiedAt,
    this.error,
    this.details = const {},
  });

  @override
  List<Object?> get props => [
        result,
        domain,
        ipAddress,
        spfRecord,
        verifiedAt,
        error,
        details,
      ];

  SPFVerificationResult copyWith({
    SPFResult? result,
    String? domain,
    String? ipAddress,
    String? spfRecord,
    DateTime? verifiedAt,
    String? error,
    Map<String, dynamic>? details,
  }) {
    return SPFVerificationResult(
      result: result ?? this.result,
      domain: domain ?? this.domain,
      ipAddress: ipAddress ?? this.ipAddress,
      spfRecord: spfRecord ?? this.spfRecord,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() => _$SPFVerificationResultToJson(this);
  factory SPFVerificationResult.fromJson(Map<String, dynamic> json) => _$SPFVerificationResultFromJson(json);
}

/// Результат верификации DMARC
@JsonSerializable()
class DMARCVerificationResult extends Equatable {
  /// Результат проверки DMARC
  final DMARCResult result;

  /// Домен отправителя
  final String? domain;

  /// Результат DKIM
  final DKIMVerificationResult? dkimResult;

  /// Результат SPF
  final SPFVerificationResult? spfResult;

  /// DMARC политика
  final DMARCPolicy? policy;

  /// Время верификации
  final DateTime? verifiedAt;

  /// Сообщение об ошибке
  final String? error;

  /// Дополнительные детали
  final Map<String, dynamic> details;

  const DMARCVerificationResult({
    required this.result,
    this.domain,
    this.dkimResult,
    this.spfResult,
    this.policy,
    this.verifiedAt,
    this.error,
    this.details = const {},
  });

  @override
  List<Object?> get props => [
        result,
        domain,
        dkimResult,
        spfResult,
        policy,
        verifiedAt,
        error,
        details,
      ];

  DMARCVerificationResult copyWith({
    DMARCResult? result,
    String? domain,
    DKIMVerificationResult? dkimResult,
    SPFVerificationResult? spfResult,
    DMARCPolicy? policy,
    DateTime? verifiedAt,
    String? error,
    Map<String, dynamic>? details,
  }) {
    return DMARCVerificationResult(
      result: result ?? this.result,
      domain: domain ?? this.domain,
      dkimResult: dkimResult ?? this.dkimResult,
      spfResult: spfResult ?? this.spfResult,
      policy: policy ?? this.policy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      error: error ?? this.error,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() => _$DMARCVerificationResultToJson(this);
  factory DMARCVerificationResult.fromJson(Map<String, dynamic> json) => _$DMARCVerificationResultFromJson(json);
}

/// DKIM подпись
@JsonSerializable()
class DKIMSignature extends Equatable {
  /// Версия DKIM
  final String version;

  /// Алгоритм подписи
  final String algorithm;

  /// Домен
  final String domain;

  /// Селектор
  final String selector;

  /// Подпись
  final String signature;

  /// Заголовки, включенные в подпись
  final List<String> signedHeaders;

  /// Тело сообщения, включенное в подпись
  final String? bodyHash;

  /// Время создания подписи
  final DateTime? timestamp;

  /// Время истечения подписи
  final DateTime? expires;

  const DKIMSignature({
    required this.version,
    required this.algorithm,
    required this.domain,
    required this.selector,
    required this.signature,
    this.signedHeaders = const [],
    this.bodyHash,
    this.timestamp,
    this.expires,
  });

  @override
  List<Object?> get props => [
        version,
        algorithm,
        domain,
        selector,
        signature,
        signedHeaders,
        bodyHash,
        timestamp,
        expires,
      ];

  Map<String, dynamic> toJson() => _$DKIMSignatureToJson(this);
  factory DKIMSignature.fromJson(Map<String, dynamic> json) => _$DKIMSignatureFromJson(json);
}

/// DMARC политика
@JsonSerializable()
class DMARCPolicy extends Equatable {
  /// Версия DMARC
  final String version;

  /// Политика обработки (none, quarantine, reject)
  final String policy;

  /// Процент сообщений для применения политики
  final int percentage;

  /// Действие при неуспешной DKIM верификации
  final String? dkimFailureAction;

  /// Действие при неуспешной SPF верификации
  final String? spfFailureAction;

  /// Адрес для отправки отчетов
  final String? reportEmail;

  /// Интервал отправки отчетов
  final int? reportInterval;

  /// Дополнительные параметры
  final Map<String, dynamic> parameters;

  const DMARCPolicy({
    required this.version,
    required this.policy,
    this.percentage = 100,
    this.dkimFailureAction,
    this.spfFailureAction,
    this.reportEmail,
    this.reportInterval,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
        version,
        policy,
        percentage,
        dkimFailureAction,
        spfFailureAction,
        reportEmail,
        reportInterval,
        parameters,
      ];

  Map<String, dynamic> toJson() => _$DMARCPolicyToJson(this);
  factory DMARCPolicy.fromJson(Map<String, dynamic> json) => _$DMARCPolicyFromJson(json);
}

/// Результаты SPF
enum SPFResult {
  @JsonValue('pass')
  pass,
  @JsonValue('fail')
  fail,
  @JsonValue('softfail')
  softfail,
  @JsonValue('neutral')
  neutral,
  @JsonValue('temperror')
  temperror,
  @JsonValue('permerror')
  permerror,
  @JsonValue('none')
  none,
  @JsonValue('error')
  error,
}

/// Результаты DMARC
enum DMARCResult {
  @JsonValue('pass')
  pass,
  @JsonValue('fail')
  fail,
  @JsonValue('quarantine')
  quarantine,
  @JsonValue('reject')
  reject,
  @JsonValue('none')
  none,
  @JsonValue('error')
  error,
}
