enum IntegrityCheckType {
  fileIntegrity,
  dataConsistency,
  encryptionValidation,
  compressionValidation,
  metadataValidation,
}

enum RecoveryStrategy {
  latestBackup,
  specificBackup,
  incrementalRestore,
  partialRestore,
}

enum RecoveryOptionType {
  localBackup,
  cloudBackup,
  incrementalBackup,
  disasterRecovery,
}
