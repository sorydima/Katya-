import 'package:equatable/equatable.dart';

enum SecurityEventType {
  login,
  logout,
  passwordChange,
  twoFactorEnabled,
  twoFactorDisabled,
  deviceAdded,
  deviceRemoved,
  suspiciousActivity,
  keyBackupCreated,
  keyBackupRestored,
  keyBackupDeleted,
}

class SecurityEvent extends Equatable {
  final String id;
  final SecurityEventType type;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, type, timestamp];

  SecurityEvent copyWith({
    String? id,
    SecurityEventType? type,
    String? description,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'metadata': metadata,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] as String,
      type: _securityEventTypeFromString(json['type'] as String),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static SecurityEventType _securityEventTypeFromString(String value) {
    final typeString = value.split('.').last;
    return SecurityEventType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => SecurityEventType.suspiciousActivity,
    );
  }
}
