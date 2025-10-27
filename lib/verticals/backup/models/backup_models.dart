import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backup_models.g.dart';

@JsonSerializable()
class BackupData extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String version;
  final User user;
  final List<Room> rooms;
  final List<Event> events;
  final BackupMetadata metadata;

  const BackupData({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.version,
    required this.user,
    this.rooms = const [],
    this.events = const [],
    required this.metadata,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) => _$BackupDataFromJson(json);
  Map<String, dynamic> toJson() => _$BackupDataToJson(this);

  @override
  List<Object?> get props => [id, userId, createdAt, version, user, rooms, events, metadata];
}

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, username, displayName, avatarUrl];
}

@JsonSerializable()
class Room extends Equatable {
  final String id;
  final String name;
  final String? topic;
  final List<String> members;

  const Room({
    required this.id,
    required this.name,
    this.topic,
    this.members = const [],
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [id, name, topic, members];
}

@JsonSerializable()
class Event extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final int timestamp;

  const Event({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  List<Object?> get props => [id, roomId, senderId, content, timestamp];
}

@JsonSerializable()
class BackupMetadata extends Equatable {
  final String platform;
  final String platformVersion;
  final String appVersion;
  final String backupVersion;
  final int totalRooms;
  final int totalEvents;
  final int totalSize;

  const BackupMetadata({
    required this.platform,
    required this.platformVersion,
    required this.appVersion,
    required this.backupVersion,
    this.totalRooms = 0,
    this.totalEvents = 0,
    this.totalSize = 0,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => _$BackupMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$BackupMetadataToJson(this);

  @override
  List<Object?> get props => [platform, platformVersion, appVersion, backupVersion, totalRooms, totalEvents, totalSize];
}

@JsonSerializable()
class IncrementalBackup extends Equatable {
  final String id;
  final String baseBackupId;
  final String userId;
  final DateTime createdAt;
  final List<BackupChange> changes;

  const IncrementalBackup({
    required this.id,
    required this.baseBackupId,
    required this.userId,
    required this.createdAt,
    this.changes = const [],
  });

  factory IncrementalBackup.fromJson(Map<String, dynamic> json) => _$IncrementalBackupFromJson(json);
  Map<String, dynamic> toJson() => _$IncrementalBackupToJson(this);

  @override
  List<Object?> get props => [id, baseBackupId, userId, createdAt, changes];
}

@JsonSerializable()
class BackupChange extends Equatable {
  final String type;
  final String id;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const BackupChange({
    required this.type,
    required this.id,
    required this.data,
    required this.timestamp,
  });

  factory BackupChange.fromJson(Map<String, dynamic> json) => _$BackupChangeFromJson(json);
  Map<String, dynamic> toJson() => _$BackupChangeToJson(this);

  @override
  List<Object?> get props => [type, id, data, timestamp];
}

@JsonSerializable()
class BackupManifest extends Equatable {
  final String backupId;
  final DateTime createdAt;
  final String checksum;
  final int fileSize;
  final bool encryptionUsed;
  final bool compressionUsed;

  const BackupManifest({
    required this.backupId,
    required this.createdAt,
    required this.checksum,
    required this.fileSize,
    this.encryptionUsed = false,
    this.compressionUsed = false,
  });

  factory BackupManifest.fromJson(Map<String, dynamic> json) => _$BackupManifestFromJson(json);
  Map<String, dynamic> toJson() => _$BackupManifestToJson(this);

  @override
  List<Object?> get props => [backupId, createdAt, checksum, fileSize, encryptionUsed, compressionUsed];
}

@JsonSerializable()
class BackupResult extends Equatable {
  final bool success;
  final String? backupId;
  final String? path;
  final int? size;
  final DateTime? createdAt;
  final String? error;

  const BackupResult({
    required this.success,
    this.backupId,
    this.path,
    this.size,
    this.createdAt,
    this.error,
  });

  const BackupResult.success({
    this.backupId,
    this.path,
    this.size,
    this.createdAt,
  }) : success = true, error = null;

  const BackupResult.failure({this.error}) : success = false, backupId = null, path = null, size = null, createdAt = null;

  factory BackupResult.fromJson(Map<String, dynamic> json) => _$BackupResultFromJson(json);
  Map<String, dynamic> toJson() => _$BackupResultToJson(this);

  @override
  List<Object?> get props => [success, backupId, path, size, createdAt, error];
}

@JsonSerializable()
class RestoreResult extends Equatable {
  final bool success;
  final String? backupId;
  final DateTime? restoredAt;
  final int? itemsRestored;
  final List<String>? warnings;
  final String? error;

  const RestoreResult({
    required this.success,
    this.backupId,
    this.restoredAt,
    this.itemsRestored,
    this.warnings,
    this.error,
  });

  const RestoreResult.success({
    this.backupId,
    this.restoredAt,
    this.itemsRestored,
    this.warnings,
  }) : success = true, error = null;

  const RestoreResult.failure({this.error}) : success = false, backupId = null, restoredAt = null, itemsRestored = null, warnings = null;

  factory RestoreResult.fromJson(Map<String, dynamic> json) => _$RestoreResultFromJson(json);
  Map<String, dynamic> toJson() => _$RestoreResultToJson(this);

  @override
  List<Object?> get props => [success, backupId, restoredAt, itemsRestored, warnings, error];
}

@JsonSerializable()
class RestoreResultData extends Equatable {
  final int itemsRestored;
  final List<String> warnings;

  const RestoreResultData({
    this.itemsRestored = 0,
    this.warnings = const [],
  });

  factory RestoreResultData.fromJson(Map<String, dynamic> json) => _$RestoreResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$RestoreResultDataToJson(this);

  @override
  List<Object?> get props => [itemsRestored, warnings];
}

@JsonSerializable()
class BackupVerificationResult extends Equatable {
  final bool isValid;
  final String? backupId;
  final int? fileSize;
  final DateTime? createdAt;
  final String? error;

  const BackupVerificationResult({
    required this.isValid,
    this.backupId,
    this.fileSize,
    this.createdAt,
    this.error,
  });

  const BackupVerificationResult.success({
    this.backupId,
    this.fileSize,
    this.createdAt,
  }) : isValid = true, error = null;

  const BackupVerificationResult.failure({this.error}) : isValid = false, backupId = null, fileSize = null, createdAt = null;

  factory BackupVerificationResult.fromJson(Map<String, dynamic> json) => _$BackupVerificationResultFromJson(json);
  Map<String, dynamic> toJson() => _$BackupVerificationResultToJson(this);

  @override
  List<Object?> get props => [isValid, backupId, fileSize, createdAt, error];
}

@JsonSerializable()
class CloudBackupResult extends Equatable {
  final bool success;
  final String? backupId;
  final String? cloudPath;
  final DateTime? uploadedAt;
  final String? error;

  const CloudBackupResult({
    required this.success,
    this.backupId,
    this.cloudPath,
    this.uploadedAt,
    this.error,
  });

  const CloudBackupResult.success({
    this.backupId,
    this.cloudPath,
    this.uploadedAt,
  }) : success = true, error = null;

  const CloudBackupResult.failure({this.error}) : success = false, backupId = null, cloudPath = null, uploadedAt = null;

  factory CloudBackupResult.fromJson(Map<String, dynamic> json) => _$CloudBackupResultFromJson(json);
  Map<String, dynamic> toJson() => _$CloudBackupResultToJson(this);

  @override
  List<Object?> get props => [success, backupId, cloudPath, uploadedAt, error];
}

@JsonSerializable()
class CloudRestoreResult extends Equatable {
  final bool success;
  final String? backupId;
  final DateTime? downloadedAt;
  final String? error;

  const CloudRestoreResult({
    required this.success,
    this.backupId,
    this.downloadedAt,
    this.error,
  });

  const CloudRestoreResult.success({
    this.backupId,
    this.downloadedAt,
  }) : success = true, error = null;

  const CloudRestoreResult.failure({this.error}) : success = false, backupId = null, downloadedAt = null;

  factory CloudRestoreResult.fromJson(Map<String, dynamic> json) => _$CloudRestoreResultFromJson(json);
  Map<String, dynamic> toJson() => _$CloudRestoreResultToJson(this);

  @override
  List<Object?> get props => [success, backupId, downloadedAt, error];
}

@JsonSerializable()
class CloudBackupInfo extends Equatable {
  final String backupId;
  final String cloudPath;
  final DateTime uploadedAt;
  final int fileSize;
  final String checksum;

  const CloudBackupInfo({
    required this.backupId,
    required this.cloudPath,
    required this.uploadedAt,
    required this.fileSize,
    required this.checksum,
  });

  factory CloudBackupInfo.fromJson(Map<String, dynamic> json) => _$CloudBackupInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CloudBackupInfoToJson(this);

  @override
  List<Object?> get props => [backupId, cloudPath, uploadedAt, fileSize, checksum];
}

@JsonSerializable()
class DisasterRecoveryResult extends Equatable {
  final bool success;
  final String? userId;
  final BackupData? backupUsed;
  final DateTime? restoredAt;
  final int? itemsRestored;
  final String? error;

  const DisasterRecoveryResult({
    required this.success,
    this.userId,
    this.backupUsed,
    this.restoredAt,
    this.itemsRestored,
    this.error,
  });

  const DisasterRecoveryResult.success({
    this.userId,
    this.backupUsed,
    this.restoredAt,
    this.itemsRestored,
  }) : success = true, error = null;

  const DisasterRecoveryResult.failure({this.error}) : success = false, userId = null, backupUsed = null, restoredAt = null, itemsRestored = null;

  factory DisasterRecoveryResult.fromJson(Map<String, dynamic> json) => _$DisasterRecoveryResultFromJson(json);
  Map<String, dynamic> toJson() => _$DisasterRecoveryResultToJson(this);

  @override
  List<Object?> get props => [success, userId, backupUsed, restoredAt, itemsRestored, error];
}

@JsonSerializable()
class IntegrityCheckResult extends Equatable {
  final bool isValid;
  final String? userId;
  final List<IntegrityCheck> checks;
  final DateTime? checkedAt;
  final String? error;

  const IntegrityCheckResult({
    required this.isValid,
    this.userId,
    this.checks = const [],
    this.checkedAt,
    this.error,
  });

  const IntegrityCheckResult.success({
    this.userId,
    this.checks = const [],
    this.checkedAt,
  }) : isValid = true, error = null;

  const IntegrityCheckResult.failure({this.error}) : isValid = false, userId = null, checks = const [], checkedAt = null;

  factory IntegrityCheckResult.fromJson(Map<String, dynamic> json) => _$IntegrityCheckResultFromJson(json);
  Map<String, dynamic> toJson() => _$IntegrityCheckResultToJson(this);

  @override
  List<Object?> get props => [isValid, userId, checks, checkedAt, error];
}

@JsonSerializable()
class IntegrityCheck extends Equatable {
  final IntegrityCheckType type;
  final bool isValid;
  final String description;
  final List<String>? issues;

  const IntegrityCheck({
    required this.type,
    required this.isValid,
    required this.description,
    this.issues,
  });

  factory IntegrityCheck.fromJson(Map<String, dynamic> json) => _$IntegrityCheckFromJson(json);
  Map<String, dynamic> toJson() => _$IntegrityCheckToJson(this);

  @override
  List<Object?> get props => [type, isValid, description, issues];
}

@JsonSerializable()
class RecoveryPlan extends Equatable {
  final String userId;
  final RecoveryStrategy strategy;
  final List<RecoveryOption> backupOptions;
  final Duration estimatedRecoveryTime;
  final DateTime createdAt;

  const RecoveryPlan({
    required this.userId,
    required this.strategy,
    this.backupOptions = const [],
    required this.estimatedRecoveryTime,
    required this.createdAt,
  });

  factory RecoveryPlan.fromJson(Map<String, dynamic> json) => _$RecoveryPlanFromJson(json);
  Map<String, dynamic> toJson() => _$RecoveryPlanToJson(this);

  @override
  List<Object?> get props => [userId, strategy, backupOptions, estimatedRecoveryTime, createdAt];
}

@JsonSerializable()
class RecoveryOption extends Equatable {
  final RecoveryOptionType type;
  final bool available;
  final BackupData? latestBackup;

  const RecoveryOption({
    required this.type,
    this.available = false,
    this.latestBackup,
  });

  factory RecoveryOption.fromJson(Map<String, dynamic> json) => _$RecoveryOptionFromJson(json);
  Map<String, dynamic> toJson() => _$RecoveryOptionToJson(this);

  @override
  List<Object?> get props => [type, available, latestBackup];
}

@JsonSerializable()
class BackupOptions extends Equatable {
  final bool encrypt;
  final bool compress;
  final bool includeMedia;
  final bool includeProfile;

  const BackupOptions({
    this.encrypt = false,
    this.compress = true,
    this.includeMedia = true,
    this.includeProfile = true,
  });

  factory BackupOptions.fromJson(Map<String, dynamic> json) => _$BackupOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$BackupOptionsToJson(this);

  @override
  List<Object?> get props => [encrypt, compress, includeMedia, includeProfile];
}

@JsonSerializable()
class RestoreOptions extends Equatable {
  final bool decrypt;
  final bool decompress;
  final bool restoreMedia;
  final bool restoreProfile;
  final bool overwriteExisting;

  const RestoreOptions({
    this.decrypt = false,
    this.decompress = true,
    this.restoreMedia = true,
    this.restoreProfile = true,
    this.overwriteExisting = false,
  });

  factory RestoreOptions.fromJson(Map<String, dynamic> json) => _$RestoreOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$RestoreOptionsToJson(this);

  @override
  List<Object?> get props => [decrypt, decompress, restoreMedia, restoreProfile, overwriteExisting];
}

@JsonSerializable()
class CloudUploadOptions extends Equatable {
  final bool encrypt;
  final bool compress;
  final String? customPath;

  const CloudUploadOptions({
    this.encrypt = false,
    this.compress = true,
    this.customPath,
  });

  factory CloudUploadOptions.fromJson(Map<String, dynamic> json) => _$CloudUploadOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$CloudUploadOptionsToJson(this);

  @override
  List<Object?> get props => [encrypt, compress, customPath];
}

@JsonSerializable()
class ExportOptions extends Equatable {
  final bool verifyExport;
  final String? customFormat;

  const ExportOptions({
    this.verifyExport = true,
    this.customFormat,
  });

  factory ExportOptions.fromJson(Map<String, dynamic> json) => _$ExportOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$ExportOptionsToJson(this);

  @override
  List<Object?> get props => [verifyExport, customFormat];
}

@JsonSerializable()
class BackupSchedule extends Equatable {
  final Duration interval;
  final bool enabled;
  final DateTime? nextRun;

  const BackupSchedule({
    required this.interval,
    this.enabled = true,
    this.nextRun,
  });

  factory BackupSchedule.fromJson(Map<String, dynamic> json) => _$BackupScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$BackupScheduleToJson(this);

  @override
  List<Object?> get props => [interval, enabled, nextRun];
}

@JsonSerializable()
class RecoveryPlanOptions extends Equatable {
  final RecoveryStrategy strategy;
  final bool includeMedia;

  const RecoveryPlanOptions({
    this.strategy = RecoveryStrategy.latestBackup,
    this.includeMedia = true,
  });

  factory RecoveryPlanOptions.fromJson(Map<String, dynamic> json) => _$RecoveryPlanOptionsFromJson(json);
  Map<String, dynamic> toJson() => _$RecoveryPlanOptionsToJson(this);

  @override
  List<Object?> get props => [strategy, includeMedia];
}
