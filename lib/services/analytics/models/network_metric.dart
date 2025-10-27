import 'package:equatable/equatable.dart';

/// Тип сетевой метрики
enum MetricType {
  bandwidth,
  latency,
  packetLoss,
  throughput,
  connectionCount,
  errorRate,
}

/// Важность метрики
enum MetricImportance {
  low,
  medium,
  high,
  critical,
}

/// Модель сетевой метрики
class NetworkMetric extends Equatable {
  final String id;
  final String name;
  final String description;
  final MetricType type;
  final double value;
  final double threshold;
  final String unit;
  final MetricImportance importance;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const NetworkMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.threshold,
    required this.unit,
    required this.importance,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        value,
        threshold,
        unit,
        importance,
        timestamp,
        metadata,
      ];

  NetworkMetric copyWith({
    String? id,
    String? name,
    String? description,
    MetricType? type,
    double? value,
    double? threshold,
    String? unit,
    MetricImportance? importance,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return NetworkMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      threshold: threshold ?? this.threshold,
      unit: unit ?? this.unit,
      importance: importance ?? this.importance,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  factory NetworkMetric.fromJson(Map<String, dynamic> json) {
    return NetworkMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: MetricType.values.firstWhere(
        (e) => e.toString() == 'MetricType.${json['type']}',
        orElse: () => MetricType.bandwidth,
      ),
      value: (json['value'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      unit: json['unit'] as String,
      importance: MetricImportance.values.firstWhere(
        (e) => e.toString() == 'MetricImportance.${json['importance']}',
        orElse: () => MetricImportance.medium,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'threshold': threshold,
      'unit': unit,
      'importance': importance.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

