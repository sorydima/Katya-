import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 's7_data_block.g.dart';

/// Модель блока данных S7
@JsonSerializable()
class S7DataBlock extends Equatable {
  /// Номер блока данных
  final int dbNumber;

  /// Начальный байт
  final int startByte;

  /// Данные
  @JsonKey(ignore: true)
  final Uint8List data;

  /// Временная метка
  final DateTime timestamp;

  /// Тип данных
  final S7DataType dataType;

  /// Размер данных в байтах
  final int byteCount;

  /// Качество данных
  final DataQuality quality;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const S7DataBlock({
    required this.dbNumber,
    required this.startByte,
    required this.data,
    required this.timestamp,
    this.dataType = S7DataType.bytes,
    required this.byteCount,
    this.quality = DataQuality.good,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        dbNumber,
        startByte,
        data,
        timestamp,
        dataType,
        byteCount,
        quality,
        metadata,
      ];

  S7DataBlock copyWith({
    int? dbNumber,
    int? startByte,
    Uint8List? data,
    DateTime? timestamp,
    S7DataType? dataType,
    int? byteCount,
    DataQuality? quality,
    Map<String, dynamic>? metadata,
  }) {
    return S7DataBlock(
      dbNumber: dbNumber ?? this.dbNumber,
      startByte: startByte ?? this.startByte,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      dataType: dataType ?? this.dataType,
      byteCount: byteCount ?? this.byteCount,
      quality: quality ?? this.quality,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Чтение байта по индексу
  int readByte(int index) {
    if (index < 0 || index >= data.length) {
      throw RangeError('Index $index is out of range [0, ${data.length})');
    }
    return data[index];
  }

  /// Чтение слова (16 бит)
  int readWord(int index) {
    if (index < 0 || index + 1 >= data.length) {
      throw RangeError('Index $index is out of range for word reading');
    }
    return (data[index] << 8) | data[index + 1];
  }

  /// Чтение двойного слова (32 бита)
  int readDWord(int index) {
    if (index < 0 || index + 3 >= data.length) {
      throw RangeError('Index $index is out of range for dword reading');
    }
    return (data[index] << 24) | (data[index + 1] << 16) | (data[index + 2] << 8) | data[index + 3];
  }

  /// Чтение вещественного числа
  double readReal(int index) {
    if (index < 0 || index + 3 >= data.length) {
      throw RangeError('Index $index is out of range for real reading');
    }

    // Преобразование IEEE 754 float
    final bits = readDWord(index);
    return _bitsToFloat(bits);
  }

  /// Запись байта
  S7DataBlock writeByte(int index, int value) {
    if (index < 0 || index >= data.length) {
      throw RangeError('Index $index is out of range [0, ${data.length})');
    }

    final newData = Uint8List.fromList(data);
    newData[index] = value & 0xFF;

    return copyWith(data: newData, timestamp: DateTime.now());
  }

  /// Запись слова
  S7DataBlock writeWord(int index, int value) {
    if (index < 0 || index + 1 >= data.length) {
      throw RangeError('Index $index is out of range for word writing');
    }

    final newData = Uint8List.fromList(data);
    newData[index] = (value >> 8) & 0xFF;
    newData[index + 1] = value & 0xFF;

    return copyWith(data: newData, timestamp: DateTime.now());
  }

  /// Запись двойного слова
  S7DataBlock writeDWord(int index, int value) {
    if (index < 0 || index + 3 >= data.length) {
      throw RangeError('Index $index is out of range for dword writing');
    }

    final newData = Uint8List.fromList(data);
    newData[index] = (value >> 24) & 0xFF;
    newData[index + 1] = (value >> 16) & 0xFF;
    newData[index + 2] = (value >> 8) & 0xFF;
    newData[index + 3] = value & 0xFF;

    return copyWith(data: newData, timestamp: DateTime.now());
  }

  /// Запись вещественного числа
  S7DataBlock writeReal(int index, double value) {
    if (index < 0 || index + 3 >= data.length) {
      throw RangeError('Index $index is out of range for real writing');
    }

    final bits = _floatToBits(value);
    return writeDWord(index, bits);
  }

  /// Получение данных в виде строки
  String getStringData({String encoding = 'utf-8'}) {
    try {
      return String.fromCharCodes(data);
    } catch (e) {
      return 'Invalid string data';
    }
  }

  /// Получение данных в виде hex строки
  String getHexData() {
    return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  /// Проверка валидности данных
  bool get isValid {
    return data.isNotEmpty && byteCount == data.length && quality == DataQuality.good;
  }

  /// Получение описания качества данных
  String get qualityDescription {
    switch (quality) {
      case DataQuality.good:
        return 'Good';
      case DataQuality.uncertain:
        return 'Uncertain';
      case DataQuality.bad:
        return 'Bad';
      case DataQuality.unavailable:
        return 'Unavailable';
    }
  }

  /// Преобразование битов в float
  double _bitsToFloat(int bits) {
    // Упрощенная реализация для IEEE 754
    // В реальной реализации здесь должна быть полная поддержка IEEE 754
    return bits.toDouble();
  }

  /// Преобразование float в биты
  int _floatToBits(double value) {
    // Упрощенная реализация для IEEE 754
    // В реальной реализации здесь должна быть полная поддержка IEEE 754
    return value.toInt();
  }

  Map<String, dynamic> toJson() => _$S7DataBlockToJson(this);
  factory S7DataBlock.fromJson(Map<String, dynamic> json) => _$S7DataBlockFromJson(json);
}

/// Типы данных S7
enum S7DataType {
  @JsonValue('bytes')
  bytes,
  @JsonValue('word')
  word,
  @JsonValue('dword')
  dword,
  @JsonValue('real')
  real,
  @JsonValue('string')
  string,
  @JsonValue('bool')
  bool,
  @JsonValue('int')
  int,
  @JsonValue('uint')
  uint,
  @JsonValue('dint')
  dint,
  @JsonValue('udint')
  udint,
  @JsonValue('time')
  time,
  @JsonValue('date')
  date,
  @JsonValue('time_of_day')
  timeOfDay,
}

/// Качество данных
enum DataQuality {
  @JsonValue('good')
  good,
  @JsonValue('uncertain')
  uncertain,
  @JsonValue('bad')
  bad,
  @JsonValue('unavailable')
  unavailable,
}

/// Дескриптор блока данных
@JsonSerializable()
class S7DataBlockDescriptor extends Equatable {
  /// Номер блока данных
  final int dbNumber;

  /// Название блока
  final String name;

  /// Описание блока
  final String description;

  /// Размер блока в байтах
  final int size;

  /// Тип блока
  final BlockType blockType;

  /// Адресные области
  final List<AddressArea> addressAreas;

  /// Переменные
  final List<S7Variable> variables;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const S7DataBlockDescriptor({
    required this.dbNumber,
    required this.name,
    this.description = '',
    required this.size,
    this.blockType = BlockType.dataBlock,
    this.addressAreas = const [],
    this.variables = const [],
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        dbNumber,
        name,
        description,
        size,
        blockType,
        addressAreas,
        variables,
        metadata,
      ];

  Map<String, dynamic> toJson() => _$S7DataBlockDescriptorToJson(this);
  factory S7DataBlockDescriptor.fromJson(Map<String, dynamic> json) => _$S7DataBlockDescriptorFromJson(json);
}

/// Тип блока
enum BlockType {
  @JsonValue('data_block')
  dataBlock,
  @JsonValue('function_block')
  functionBlock,
  @JsonValue('function')
  function,
  @JsonValue('organization_block')
  organizationBlock,
}

/// Адресная область
@JsonSerializable()
class AddressArea extends Equatable {
  /// Название области
  final String name;

  /// Начальный адрес
  final int startAddress;

  /// Конечный адрес
  final int endAddress;

  /// Тип данных
  final S7DataType dataType;

  /// Описание
  final String description;

  const AddressArea({
    required this.name,
    required this.startAddress,
    required this.endAddress,
    required this.dataType,
    this.description = '',
  });

  @override
  List<Object?> get props => [
        name,
        startAddress,
        endAddress,
        dataType,
        description,
      ];

  Map<String, dynamic> toJson() => _$AddressAreaToJson(this);
  factory AddressArea.fromJson(Map<String, dynamic> json) => _$AddressAreaFromJson(json);
}

/// Переменная S7
@JsonSerializable()
class S7Variable extends Equatable {
  /// Название переменной
  final String name;

  /// Адрес
  final int address;

  /// Тип данных
  final S7DataType dataType;

  /// Размер в байтах
  final int size;

  /// Описание
  final String description;

  /// Единицы измерения
  final String? unit;

  /// Минимальное значение
  final double? minValue;

  /// Максимальное значение
  final double? maxValue;

  const S7Variable({
    required this.name,
    required this.address,
    required this.dataType,
    required this.size,
    this.description = '',
    this.unit,
    this.minValue,
    this.maxValue,
  });

  @override
  List<Object?> get props => [
        name,
        address,
        dataType,
        size,
        description,
        unit,
        minValue,
        maxValue,
      ];

  Map<String, dynamic> toJson() => _$S7VariableToJson(this);
  factory S7Variable.fromJson(Map<String, dynamic> json) => _$S7VariableFromJson(json);
}
