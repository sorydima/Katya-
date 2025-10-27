import 'package:equatable/equatable.dart';

class IPWhitelistRule extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final String? subnetMask;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  IPWhitelistRule({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.subnetMask,
    DateTime? createdAt,
    this.expiresAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [id, name, ipAddress, subnetMask, createdAt, expiresAt, isActive];

  IPWhitelistRule copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? subnetMask,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return IPWhitelistRule(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      subnetMask: subnetMask ?? this.subnetMask,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'subnetMask': subnetMask,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory IPWhitelistRule.fromJson(Map<String, dynamic> json) {
    return IPWhitelistRule(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      subnetMask: json['subnetMask'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  bool matches(String ip) {
    // Simple IP matching (exact match for now)
    // TODO: Implement proper IP range matching with subnet support
    return ip == ipAddress;
  }
}
