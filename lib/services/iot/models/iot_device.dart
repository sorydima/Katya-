import 'package:equatable/equatable.dart';

/// Модель IoT устройства
class IoTDevice extends Equatable {
  final String id;
  final String name;
  final String type;
  final String status;
  final String location;
  final DateTime lastSeen;
  final Map<String, dynamic>? properties;

  const IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.location,
    required this.lastSeen,
    this.properties,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        status,
        location,
        lastSeen,
        properties,
      ];

  IoTDevice copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    String? location,
    DateTime? lastSeen,
    Map<String, dynamic>? properties,
  }) {
    return IoTDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      lastSeen: lastSeen ?? this.lastSeen,
      properties: properties ?? this.properties,
    );
  }

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      location: json['location'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'location': location,
      'lastSeen': lastSeen.toIso8601String(),
      'properties': properties,
    };
  }
}
