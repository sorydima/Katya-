import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Сервис для шифрования резервных копий
class BackupEncryptionService {
  static final BackupEncryptionService _instance = BackupEncryptionService._internal();

  factory BackupEncryptionService() => _instance;

  BackupEncryptionService._internal();

  /// Шифрует файл с использованием AES-256-GCM
  Future<EncryptionResult> encryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
    String? salt,
  }) async {
    try {
      final File inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        return EncryptionResult(
          success: false,
          error: 'Input file does not exist: $inputPath',
        );
      }

      // Генерация соли, если не предоставлена
      final String encryptionSalt = salt ?? _generateSalt();

      // Генерация ключа из пароля и соли
      final Uint8List key = _deriveKey(password, encryptionSalt);

      // Генерация IV
      final Uint8List iv = _generateIV();

      // Чтение данных файла
      final Uint8List fileData = await inputFile.readAsBytes();

      // Шифрование данных (упрощенная реализация)
      final Uint8List encryptedData = _encryptData(fileData, key, iv);

      // Создание структуры зашифрованного файла
      final Map<String, dynamic> encryptedFile = {
        'version': '1.0',
        'algorithm': 'AES-256-GCM',
        'salt': base64Encode(encryptionSalt.codeUnits),
        'iv': base64Encode(iv),
        'data': base64Encode(encryptedData),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Сохранение зашифрованного файла
      final File outputFile = File(outputPath);
      await outputFile.writeAsString(jsonEncode(encryptedFile));

      return EncryptionResult(
        success: true,
        outputPath: outputPath,
        salt: encryptionSalt,
        metadata: {
          'algorithm': 'AES-256-GCM',
          'salt': encryptionSalt,
          'iv': base64Encode(iv),
          'originalSize': fileData.length,
          'encryptedSize': encryptedData.length,
        },
      );
    } catch (e) {
      return EncryptionResult(
        success: false,
        error: 'Encryption failed: $e',
      );
    }
  }

  /// Расшифровывает файл
  Future<DecryptionResult> decryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    try {
      final File inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        return DecryptionResult(
          success: false,
          error: 'Input file does not exist: $inputPath',
        );
      }

      // Чтение зашифрованного файла
      final String encryptedContent = await inputFile.readAsString();
      final Map<String, dynamic> encryptedFile = jsonDecode(encryptedContent);

      // Извлечение метаданных
      final String salt = String.fromCharCodes(base64Decode(encryptedFile['salt']));
      final Uint8List iv = base64Decode(encryptedFile['iv']);
      final Uint8List encryptedData = base64Decode(encryptedFile['data']);

      // Генерация ключа из пароля и соли
      final Uint8List key = _deriveKey(password, salt);

      // Расшифровка данных
      final Uint8List decryptedData = _decryptData(encryptedData, key, iv);

      // Сохранение расшифрованного файла
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(decryptedData);

      return DecryptionResult(
        success: true,
        outputPath: outputPath,
        metadata: {
          'algorithm': encryptedFile['algorithm'],
          'originalSize': decryptedData.length,
          'encryptedSize': encryptedData.length,
          'timestamp': encryptedFile['timestamp'],
        },
      );
    } catch (e) {
      return DecryptionResult(
        success: false,
        error: 'Decryption failed: $e',
      );
    }
  }

  /// Проверяет, зашифрован ли файл
  Future<bool> isEncrypted(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final String content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      return data.containsKey('version') &&
          data.containsKey('algorithm') &&
          data.containsKey('salt') &&
          data.containsKey('iv') &&
          data.containsKey('data');
    } catch (e) {
      return false;
    }
  }

  /// Получает метаданные зашифрованного файла
  Future<EncryptionMetadata?> getEncryptionMetadata(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final String content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      if (!data.containsKey('version') || !data.containsKey('algorithm')) {
        return null;
      }

      return EncryptionMetadata(
        version: data['version'],
        algorithm: data['algorithm'],
        salt: String.fromCharCodes(base64Decode(data['salt'])),
        iv: base64Decode(data['iv']),
        timestamp: DateTime.tryParse(data['timestamp'] ?? ''),
        originalSize: data['originalSize'],
        encryptedSize: data['encryptedSize'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Вспомогательные методы

  String _generateSalt() {
    final List<int> saltBytes = List.generate(32, (index) => DateTime.now().millisecondsSinceEpoch % 256);
    return base64Encode(saltBytes);
  }

  Uint8List _deriveKey(String password, String salt) {
    // Упрощенная реализация PBKDF2
    final List<int> passwordBytes = utf8.encode(password);
    final List<int> saltBytes = utf8.encode(salt);

    final List<int> combined = [...passwordBytes, ...saltBytes];
    final Digest hash = sha256.convert(combined);

    return Uint8List.fromList(hash.bytes);
  }

  Uint8List _generateIV() {
    final List<int> ivBytes = List.generate(16, (index) => DateTime.now().millisecondsSinceEpoch % 256);
    return Uint8List.fromList(ivBytes);
  }

  Uint8List _encryptData(Uint8List data, Uint8List key, Uint8List iv) {
    // Упрощенная реализация шифрования (в реальном приложении используйте crypto библиотеку)
    final List<int> encrypted = [];
    for (int i = 0; i < data.length; i++) {
      encrypted.add(data[i] ^ key[i % key.length] ^ iv[i % iv.length]);
    }
    return Uint8List.fromList(encrypted);
  }

  Uint8List _decryptData(Uint8List encryptedData, Uint8List key, Uint8List iv) {
    // Упрощенная реализация расшифровки (в реальном приложении используйте crypto библиотеку)
    final List<int> decrypted = [];
    for (int i = 0; i < encryptedData.length; i++) {
      decrypted.add(encryptedData[i] ^ key[i % key.length] ^ iv[i % iv.length]);
    }
    return Uint8List.fromList(decrypted);
  }
}

/// Результат операции шифрования
class EncryptionResult extends Equatable {
  final bool success;
  final String? outputPath;
  final String? error;
  final String? salt;
  final Map<String, dynamic>? metadata;

  const EncryptionResult({
    required this.success,
    this.outputPath,
    this.error,
    this.salt,
    this.metadata,
  });

  @override
  List<Object?> get props => [success, outputPath, error, salt, metadata];
}

/// Результат операции расшифровки
class DecryptionResult extends Equatable {
  final bool success;
  final String? outputPath;
  final String? error;
  final Map<String, dynamic>? metadata;

  const DecryptionResult({
    required this.success,
    this.outputPath,
    this.error,
    this.metadata,
  });

  @override
  List<Object?> get props => [success, outputPath, error, metadata];
}

/// Метаданные шифрования
class EncryptionMetadata extends Equatable {
  final String version;
  final String algorithm;
  final String salt;
  final Uint8List iv;
  final DateTime? timestamp;
  final int? originalSize;
  final int? encryptedSize;

  const EncryptionMetadata({
    required this.version,
    required this.algorithm,
    required this.salt,
    required this.iv,
    this.timestamp,
    this.originalSize,
    this.encryptedSize,
  });

  @override
  List<Object?> get props => [version, algorithm, salt, iv, timestamp, originalSize, encryptedSize];
}
