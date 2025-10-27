import 'package:equatable/equatable.dart';
import 'package:katya/services/encryption/encryption_manager.dart';

class EncryptionState extends Equatable {
  final EncryptionManager? encryptionManager;
  final bool isEncryptionEnabled;
  final bool isCrossSigningEnabled;
  final bool isKeyBackupEnabled;
  final bool isLoading;
  final String? error;

  const EncryptionState({
    this.encryptionManager,
    this.isEncryptionEnabled = false,
    this.isCrossSigningEnabled = false,
    this.isKeyBackupEnabled = false,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        encryptionManager,
        isEncryptionEnabled,
        isCrossSigningEnabled,
        isKeyBackupEnabled,
        isLoading,
        error,
      ];

  EncryptionState copyWith({
    EncryptionManager? encryptionManager,
    bool? isEncryptionEnabled,
    bool? isCrossSigningEnabled,
    bool? isKeyBackupEnabled,
    bool? isLoading,
    String? error,
  }) {
    return EncryptionState(
      encryptionManager: encryptionManager ?? this.encryptionManager,
      isEncryptionEnabled: isEncryptionEnabled ?? this.isEncryptionEnabled,
      isCrossSigningEnabled: isCrossSigningEnabled ?? this.isCrossSigningEnabled,
      isKeyBackupEnabled: isKeyBackupEnabled ?? this.isKeyBackupEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
