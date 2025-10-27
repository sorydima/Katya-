import 'dart:io';

import 'package:equatable/equatable.dart';

/// Сервис для сжатия резервных копий
class BackupCompressionService {
  static final BackupCompressionService _instance = BackupCompressionService._internal();

  factory BackupCompressionService() => _instance;

  BackupCompressionService._internal();

  /// Сжимает файл или директорию
  Future<CompressionResult> compress({
    required String inputPath,
    required String outputPath,
    required CompressionType type,
    int compressionLevel = 6,
  }) async {
    try {
      final File inputFile = File(inputPath);
      final Directory inputDir = Directory(inputPath);

      if (!await inputFile.exists() && !await inputDir.exists()) {
        return CompressionResult(
          success: false,
          error: 'Input path does not exist: $inputPath',
        );
      }

      final int originalSize = await _getPathSize(inputPath);
      final String compressedPath = await _performCompression(
        inputPath: inputPath,
        outputPath: outputPath,
        type: type,
        compressionLevel: compressionLevel,
      );

      final int compressedSize = await File(compressedPath).length();
      final double compressionRatio = originalSize > 0 ? (1 - compressedSize / originalSize) * 100 : 0;

      return CompressionResult(
        success: true,
        outputPath: compressedPath,
        originalSize: originalSize,
        compressedSize: compressedSize,
        compressionRatio: compressionRatio,
        metadata: {
          'type': type.name,
          'compressionLevel': compressionLevel,
          'originalSize': originalSize,
          'compressedSize': compressedSize,
          'compressionRatio': compressionRatio,
        },
      );
    } catch (e) {
      return CompressionResult(
        success: false,
        error: 'Compression failed: $e',
      );
    }
  }

  /// Распаковывает сжатый файл
  Future<DecompressionResult> decompress({
    required String inputPath,
    required String outputPath,
    CompressionType? type,
  }) async {
    try {
      final File inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        return DecompressionResult(
          success: false,
          error: 'Input file does not exist: $inputPath',
        );
      }

      final int compressedSize = await inputFile.length();
      final CompressionType detectedType = type ?? _detectCompressionType(inputPath);

      final String decompressedPath = await _performDecompression(
        inputPath: inputPath,
        outputPath: outputPath,
        type: detectedType,
      );

      final int decompressedSize = await _getPathSize(decompressedPath);

      return DecompressionResult(
        success: true,
        outputPath: decompressedPath,
        compressedSize: compressedSize,
        decompressedSize: decompressedSize,
        metadata: {
          'type': detectedType.name,
          'compressedSize': compressedSize,
          'decompressedSize': decompressedSize,
        },
      );
    } catch (e) {
      return DecompressionResult(
        success: false,
        error: 'Decompression failed: $e',
      );
    }
  }

  /// Проверяет, сжат ли файл
  Future<bool> isCompressed(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final String extension = filePath.split('.').last.toLowerCase();
      return CompressionType.values.any((type) => type.extensions.contains(extension));
    } catch (e) {
      return false;
    }
  }

  /// Получает информацию о сжатом файле
  Future<CompressionInfo?> getCompressionInfo(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final CompressionType type = _detectCompressionType(filePath);
      final int size = await file.length();

      return CompressionInfo(
        type: type,
        size: size,
        extension: filePath.split('.').last.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Вспомогательные методы

  Future<int> _getPathSize(String path) async {
    final File file = File(path);
    final Directory dir = Directory(path);

    if (await file.exists()) {
      return await file.length();
    } else if (await dir.exists()) {
      int totalSize = 0;
      await for (final FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    }
    return 0;
  }

  Future<String> _performCompression({
    required String inputPath,
    required String outputPath,
    required CompressionType type,
    required int compressionLevel,
  }) async {
    // Упрощенная реализация сжатия
    // В реальном приложении используйте соответствующие библиотеки (archive, gzip, etc.)

    switch (type) {
      case CompressionType.zip:
        return await _compressZip(inputPath, outputPath, compressionLevel);
      case CompressionType.tar:
        return await _compressTar(inputPath, outputPath, compressionLevel);
      case CompressionType.gzip:
        return await _compressGzip(inputPath, outputPath, compressionLevel);
      case CompressionType.bzip2:
        return await _compressBzip2(inputPath, outputPath, compressionLevel);
      case CompressionType.lz4:
        return await _compressLz4(inputPath, outputPath, compressionLevel);
    }
  }

  Future<String> _performDecompression({
    required String inputPath,
    required String outputPath,
    required CompressionType type,
  }) async {
    // Упрощенная реализация распаковки
    // В реальном приложении используйте соответствующие библиотеки

    switch (type) {
      case CompressionType.zip:
        return await _decompressZip(inputPath, outputPath);
      case CompressionType.tar:
        return await _decompressTar(inputPath, outputPath);
      case CompressionType.gzip:
        return await _decompressGzip(inputPath, outputPath);
      case CompressionType.bzip2:
        return await _decompressBzip2(inputPath, outputPath);
      case CompressionType.lz4:
        return await _decompressLz4(inputPath, outputPath);
    }
  }

  CompressionType _detectCompressionType(String filePath) {
    final String extension = filePath.split('.').last.toLowerCase();

    for (final CompressionType type in CompressionType.values) {
      if (type.extensions.contains(extension)) {
        return type;
      }
    }

    return CompressionType.zip; // По умолчанию
  }

  // Реализации сжатия (упрощенные)
  Future<String> _compressZip(String inputPath, String outputPath, int level) async {
    // TODO: Implement actual ZIP compression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _compressTar(String inputPath, String outputPath, int level) async {
    // TODO: Implement actual TAR compression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _compressGzip(String inputPath, String outputPath, int level) async {
    // TODO: Implement actual GZIP compression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _compressBzip2(String inputPath, String outputPath, int level) async {
    // TODO: Implement actual BZIP2 compression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _compressLz4(String inputPath, String outputPath, int level) async {
    // TODO: Implement actual LZ4 compression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  // Реализации распаковки (упрощенные)
  Future<String> _decompressZip(String inputPath, String outputPath) async {
    // TODO: Implement actual ZIP decompression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _decompressTar(String inputPath, String outputPath) async {
    // TODO: Implement actual TAR decompression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _decompressGzip(String inputPath, String outputPath) async {
    // TODO: Implement actual GZIP decompression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _decompressBzip2(String inputPath, String outputPath) async {
    // TODO: Implement actual BZIP2 decompression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }

  Future<String> _decompressLz4(String inputPath, String outputPath) async {
    // TODO: Implement actual LZ4 decompression
    final File inputFile = File(inputPath);
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(await inputFile.readAsBytes());
    return outputPath;
  }
}

/// Типы сжатия
enum CompressionType {
  zip(['zip']),
  tar(['tar']),
  gzip(['gz', 'gzip']),
  bzip2(['bz2', 'bzip2']),
  lz4(['lz4']);

  const CompressionType(this.extensions);
  final List<String> extensions;
}

/// Результат операции сжатия
class CompressionResult extends Equatable {
  final bool success;
  final String? outputPath;
  final String? error;
  final int? originalSize;
  final int? compressedSize;
  final double? compressionRatio;
  final Map<String, dynamic>? metadata;

  const CompressionResult({
    required this.success,
    this.outputPath,
    this.error,
    this.originalSize,
    this.compressedSize,
    this.compressionRatio,
    this.metadata,
  });

  @override
  List<Object?> get props => [success, outputPath, error, originalSize, compressedSize, compressionRatio, metadata];
}

/// Результат операции распаковки
class DecompressionResult extends Equatable {
  final bool success;
  final String? outputPath;
  final String? error;
  final int? compressedSize;
  final int? decompressedSize;
  final Map<String, dynamic>? metadata;

  const DecompressionResult({
    required this.success,
    this.outputPath,
    this.error,
    this.compressedSize,
    this.decompressedSize,
    this.metadata,
  });

  @override
  List<Object?> get props => [success, outputPath, error, compressedSize, decompressedSize, metadata];
}

/// Информация о сжатом файле
class CompressionInfo extends Equatable {
  final CompressionType type;
  final int size;
  final String extension;

  const CompressionInfo({
    required this.type,
    required this.size,
    required this.extension,
  });

  @override
  List<Object?> get props => [type, size, extension];
}
