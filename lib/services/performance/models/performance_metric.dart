import 'package:equatable/equatable.dart';

/// Тип метрики производительности
enum MetricType {
  cpu,
  memory,
  disk,
  network,
  responseTime,
  throughput,
}

/// Модель метрики производительности
class PerformanceMetric extends Equatable {
  final String id;
  final String name;
  final MetricType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        value,
        unit,
        timestamp,
        metadata,
      ];

  PerformanceMetric copyWith({
    String? id,
    String? name,
    MetricType? type,
    double? value,
    String? unit,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MetricType.values.firstWhere(
        (e) => e.toString() == 'MetricType.${json['type']}',
        orElse: () => MetricType.cpu,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
