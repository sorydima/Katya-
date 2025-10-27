import 'package:equatable/equatable.dart';

/// Тип задачи аналитики
enum TaskType {
  dataCollection,
  dataProcessing,
  reportGeneration,
  alertMonitoring,
  trendAnalysis,
  anomalyDetection,
}

/// Приоритет задачи
enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

/// Статус задачи
enum TaskStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
  paused,
}

/// Модель задачи аналитики
class AnalyticsTask extends Equatable {
  final String id;
  final String name;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final String description;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? parameters;
  final String? errorMessage;
  final double progress;

  const AnalyticsTask({
    required this.id,
    required this.name,
    required this.type,
    required this.priority,
    required this.status,
    required this.description,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.parameters,
    this.errorMessage,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        priority,
        status,
        description,
        createdAt,
        startedAt,
        completedAt,
        parameters,
        errorMessage,
        progress,
      ];

  AnalyticsTask copyWith({
    String? id,
    String? name,
    TaskType? type,
    TaskPriority? priority,
    TaskStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? parameters,
    String? errorMessage,
    double? progress,
  }) {
    return AnalyticsTask(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      parameters: parameters ?? this.parameters,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  factory AnalyticsTask.fromJson(Map<String, dynamic> json) {
    return AnalyticsTask(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.toString() == 'TaskType.${json['type']}',
        orElse: () => TaskType.dataCollection,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.pending,
      ),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      parameters: json['parameters'] as Map<String, dynamic>?,
      errorMessage: json['errorMessage'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'parameters': parameters,
      'errorMessage': errorMessage,
      'progress': progress,
    };
  }
}

