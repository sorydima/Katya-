import 'package:equatable/equatable.dart';

/// Тип IoT команды
enum CommandType {
  read,
  write,
  execute,
  configure,
}

/// Статус выполнения IoT команды
enum CommandStatus {
  pending,
  executing,
  completed,
  failed,
}

/// IoT команда для управления устройствами
class IoTCommand extends Equatable {
  final String id;
  final CommandType type;
  final String deviceId;
  final CommandStatus status;
  final DateTime sentAt;
  final DateTime? executedAt;
  final Map<String, dynamic>? parameters;
  final String? result;
  final String? error;

  const IoTCommand({
    required this.id,
    required this.type,
    required this.deviceId,
    required this.status,
    required this.sentAt,
    this.executedAt,
    this.parameters,
    this.result,
    this.error,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        deviceId,
        status,
        sentAt,
        executedAt,
        parameters,
        result,
        error,
      ];

  IoTCommand copyWith({
    String? id,
    CommandType? type,
    String? deviceId,
    CommandStatus? status,
    DateTime? sentAt,
    DateTime? executedAt,
    Map<String, dynamic>? parameters,
    String? result,
    String? error,
  }) {
    return IoTCommand(
      id: id ?? this.id,
      type: type ?? this.type,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      executedAt: executedAt ?? this.executedAt,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  factory IoTCommand.fromJson(Map<String, dynamic> json) {
    return IoTCommand(
      id: json['id'] as String,
      type: CommandType.values.firstWhere(
        (e) => e.toString() == 'CommandType.${json['type']}',
        orElse: () => CommandType.read,
      ),
      deviceId: json['deviceId'] as String,
      status: CommandStatus.values.firstWhere(
        (e) => e.toString() == 'CommandStatus.${json['status']}',
        orElse: () => CommandStatus.pending,
      ),
      sentAt: DateTime.parse(json['sentAt'] as String),
      executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt'] as String) : null,
      parameters: json['parameters'] as Map<String, dynamic>?,
      result: json['result'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'deviceId': deviceId,
      'status': status.toString().split('.').last,
      'sentAt': sentAt.toIso8601String(),
      'executedAt': executedAt?.toIso8601String(),
      'parameters': parameters,
      'result': result,
      'error': error,
    };
  }
}
