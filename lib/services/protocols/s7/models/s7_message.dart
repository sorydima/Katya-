import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 's7_message.g.dart';

/// Модель S7 сообщения
@JsonSerializable()
class S7Message extends Equatable {
  /// Идентификатор подключения
  final String connectionId;

  /// Тип сообщения
  final S7MessageType messageType;

  /// Заголовок сообщения
  final S7Header header;

  /// Параметры сообщения
  final S7Parameters parameters;

  /// Данные сообщения
  final Uint8List data;

  /// Временная метка
  final DateTime timestamp;

  /// Идентификатор сообщения
  final int messageId;

  /// Статус сообщения
  final MessageStatus status;

  /// Код ошибки
  final int? errorCode;

  /// Сообщение об ошибке
  final String? errorMessage;

  const S7Message({
    required this.connectionId,
    required this.messageType,
    required this.header,
    required this.parameters,
    required this.data,
    required this.timestamp,
    required this.messageId,
    this.status = MessageStatus.pending,
    this.errorCode,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        connectionId,
        messageType,
        header,
        parameters,
        data,
        timestamp,
        messageId,
        status,
        errorCode,
        errorMessage,
      ];

  S7Message copyWith({
    String? connectionId,
    S7MessageType? messageType,
    S7Header? header,
    S7Parameters? parameters,
    Uint8List? data,
    DateTime? timestamp,
    int? messageId,
    MessageStatus? status,
    int? errorCode,
    String? errorMessage,
  }) {
    return S7Message(
      connectionId: connectionId ?? this.connectionId,
      messageType: messageType ?? this.messageType,
      header: header ?? this.header,
      parameters: parameters ?? this.parameters,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      messageId: messageId ?? this.messageId,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Создание запроса на чтение
  static S7Message createReadRequest({
    required String connectionId,
    required int dbNumber,
    required int startByte,
    required int byteCount,
  }) {
    const header = S7Header(
      protocolId: 0x32,
      jobType: 0x01,
      redundancyId: 0x0000,
      protocolDataUnitRef: 0x0001,
      parameterLength: 0x000C,
      dataLength: 0x0000,
      errorClass: 0x00,
      errorCode: 0x0000,
    );

    final parameters = S7Parameters(
      functionCode: 0x04, // Read
      itemCount: 0x01,
      items: [
        S7ParameterItem(
          specificationType: 0x12,
          lengthOfSpecification: 0x0A,
          specification: Uint8List.fromList([
            0x10, // Syntax ID
            0x02, // Transport size
            (byteCount >> 8) & 0xFF, // Length high byte
            byteCount & 0xFF, // Length low byte
            0x00, // DB number high byte
            dbNumber & 0xFF, // DB number low byte
            0x84, // Area code
            (startByte >> 8) & 0xFF, // Start address high byte
            startByte & 0xFF, // Start address low byte
            0x00, // Bit address
          ]),
        ),
      ],
    );

    return S7Message(
      connectionId: connectionId,
      messageType: S7MessageType.readRequest,
      header: header,
      parameters: parameters,
      data: Uint8List(0),
      timestamp: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Создание запроса на запись
  static S7Message createWriteRequest({
    required String connectionId,
    required int dbNumber,
    required int startByte,
    required Uint8List data,
  }) {
    final header = S7Header(
      protocolId: 0x32,
      jobType: 0x01,
      redundancyId: 0x0000,
      protocolDataUnitRef: 0x0001,
      parameterLength: 0x000C,
      dataLength: data.length + 4,
      errorClass: 0x00,
      errorCode: 0x0000,
    );

    final parameters = S7Parameters(
      functionCode: 0x05, // Write
      itemCount: 0x01,
      items: [
        S7ParameterItem(
          specificationType: 0x12,
          lengthOfSpecification: 0x0A,
          specification: Uint8List.fromList([
            0x10, // Syntax ID
            0x02, // Transport size
            (data.length >> 8) & 0xFF, // Length high byte
            data.length & 0xFF, // Length low byte
            0x00, // DB number high byte
            dbNumber & 0xFF, // DB number low byte
            0x84, // Area code
            (startByte >> 8) & 0xFF, // Start address high byte
            startByte & 0xFF, // Start address low byte
            0x00, // Bit address
          ]),
        ),
      ],
    );

    // Добавляем данные
    final writeData = Uint8List(data.length + 4);
    writeData[0] = 0x00; // Reserved
    writeData[1] = 0x04; // Transport size
    writeData[2] = (data.length >> 8) & 0xFF; // Length high byte
    writeData[3] = data.length & 0xFF; // Length low byte
    writeData.setRange(4, 4 + data.length, data);

    return S7Message(
      connectionId: connectionId,
      messageType: S7MessageType.writeRequest,
      header: header,
      parameters: parameters,
      data: writeData,
      timestamp: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Создание heartbeat сообщения
  static S7Message createHeartbeat(String connectionId) {
    const header = S7Header(
      protocolId: 0x32,
      jobType: 0x07, // Heartbeat
      redundancyId: 0x0000,
      protocolDataUnitRef: 0x0001,
      parameterLength: 0x0000,
      dataLength: 0x0000,
      errorClass: 0x00,
      errorCode: 0x0000,
    );

    return S7Message(
      connectionId: connectionId,
      messageType: S7MessageType.heartbeat,
      header: header,
      parameters: const S7Parameters(),
      data: Uint8List(0),
      timestamp: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Преобразование в байты
  Uint8List toBytes() {
    final headerBytes = header.toBytes();
    final parameterBytes = parameters.toBytes();

    final totalLength = headerBytes.length + parameterBytes.length + data.length;
    final message = Uint8List(totalLength);

    var offset = 0;
    message.setRange(offset, offset + headerBytes.length, headerBytes);
    offset += headerBytes.length;

    message.setRange(offset, offset + parameterBytes.length, parameterBytes);
    offset += parameterBytes.length;

    message.setRange(offset, offset + data.length, data);

    return message;
  }

  /// Создание из байтов
  static S7Message fromBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      throw Exception('Invalid S7 message: too short');
    }

    final header = S7Header.fromBytes(bytes.sublist(0, 12));
    final parameterLength = header.parameterLength;
    final dataLength = header.dataLength;

    final parameters = S7Parameters.fromBytes(bytes.sublist(12, 12 + parameterLength));
    final data = bytes.sublist(12 + parameterLength, 12 + parameterLength + dataLength);

    final messageType = _determineMessageType(header, parameters);

    return S7Message(
      connectionId: 'unknown',
      messageType: messageType,
      header: header,
      parameters: parameters,
      data: data,
      timestamp: DateTime.now(),
      messageId: DateTime.now().millisecondsSinceEpoch,
      status: header.errorCode == 0 ? MessageStatus.success : MessageStatus.error,
      errorCode: header.errorCode == 0 ? null : header.errorCode,
    );
  }

  /// Определение типа сообщения
  static S7MessageType _determineMessageType(S7Header header, S7Parameters parameters) {
    if (header.jobType == 0x07) {
      return S7MessageType.heartbeat;
    }

    if (parameters.functionCode == 0x04) {
      return header.jobType == 0x01 ? S7MessageType.readRequest : S7MessageType.readResponse;
    }

    if (parameters.functionCode == 0x05) {
      return header.jobType == 0x01 ? S7MessageType.writeRequest : S7MessageType.writeResponse;
    }

    return S7MessageType.unknown;
  }

  /// Проверка, является ли сообщение ошибкой
  bool get isError => status == MessageStatus.error || header.errorCode != 0;

  /// Получение размера сообщения
  int get size => toBytes().length;

  Map<String, dynamic> toJson() => _$S7MessageToJson(this);
  factory S7Message.fromJson(Map<String, dynamic> json) => _$S7MessageFromJson(json);
}

/// Типы S7 сообщений
enum S7MessageType {
  @JsonValue('read_request')
  readRequest,
  @JsonValue('read_response')
  readResponse,
  @JsonValue('write_request')
  writeRequest,
  @JsonValue('write_response')
  writeResponse,
  @JsonValue('heartbeat')
  heartbeat,
  @JsonValue('error')
  error,
  @JsonValue('unknown')
  unknown,
}

/// Статус сообщения
enum MessageStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sent')
  sent,
  @JsonValue('received')
  received,
  @JsonValue('success')
  success,
  @JsonValue('error')
  error,
  @JsonValue('timeout')
  timeout,
}

/// Заголовок S7 сообщения
@JsonSerializable()
class S7Header extends Equatable {
  /// Идентификатор протокола (0x32 для S7)
  final int protocolId;

  /// Тип задания
  final int jobType;

  /// Идентификатор избыточности
  final int redundancyId;

  /// Ссылка на блок данных протокола
  final int protocolDataUnitRef;

  /// Длина параметров
  final int parameterLength;

  /// Длина данных
  final int dataLength;

  /// Класс ошибки
  final int errorClass;

  /// Код ошибки
  final int errorCode;

  const S7Header({
    required this.protocolId,
    required this.jobType,
    required this.redundancyId,
    required this.protocolDataUnitRef,
    required this.parameterLength,
    required this.dataLength,
    this.errorClass = 0x00,
    this.errorCode = 0x0000,
  });

  @override
  List<Object?> get props => [
        protocolId,
        jobType,
        redundancyId,
        protocolDataUnitRef,
        parameterLength,
        dataLength,
        errorClass,
        errorCode,
      ];

  /// Преобразование в байты
  Uint8List toBytes() {
    final bytes = Uint8List(12);
    bytes[0] = protocolId;
    bytes[1] = jobType;
    bytes[2] = (redundancyId >> 8) & 0xFF;
    bytes[3] = redundancyId & 0xFF;
    bytes[4] = (protocolDataUnitRef >> 8) & 0xFF;
    bytes[5] = protocolDataUnitRef & 0xFF;
    bytes[6] = (parameterLength >> 8) & 0xFF;
    bytes[7] = parameterLength & 0xFF;
    bytes[8] = (dataLength >> 8) & 0xFF;
    bytes[9] = dataLength & 0xFF;
    bytes[10] = errorClass;
    bytes[11] = errorCode & 0xFF;
    return bytes;
  }

  /// Создание из байтов
  static S7Header fromBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      throw Exception('Invalid header: too short');
    }

    return S7Header(
      protocolId: bytes[0],
      jobType: bytes[1],
      redundancyId: (bytes[2] << 8) | bytes[3],
      protocolDataUnitRef: (bytes[4] << 8) | bytes[5],
      parameterLength: (bytes[6] << 8) | bytes[7],
      dataLength: (bytes[8] << 8) | bytes[9],
      errorClass: bytes[10],
      errorCode: bytes[11],
    );
  }

  Map<String, dynamic> toJson() => _$S7HeaderToJson(this);
  factory S7Header.fromJson(Map<String, dynamic> json) => _$S7HeaderFromJson(json);
}

/// Параметры S7 сообщения
@JsonSerializable()
class S7Parameters extends Equatable {
  /// Код функции
  final int functionCode;

  /// Количество элементов
  final int itemCount;

  /// Элементы параметров
  final List<S7ParameterItem> items;

  const S7Parameters({
    this.functionCode = 0x00,
    this.itemCount = 0x00,
    this.items = const [],
  });

  @override
  List<Object?> get props => [functionCode, itemCount, items];

  /// Преобразование в байты
  Uint8List toBytes() {
    final bytes = <int>[];
    bytes.add(functionCode);
    bytes.add(itemCount);

    for (final item in items) {
      bytes.addAll(item.toBytes());
    }

    return Uint8List.fromList(bytes);
  }

  /// Создание из байтов
  static S7Parameters fromBytes(Uint8List bytes) {
    if (bytes.length < 2) {
      throw Exception('Invalid parameters: too short');
    }

    final functionCode = bytes[0];
    final itemCount = bytes[1];

    final items = <S7ParameterItem>[];
    var offset = 2;

    for (int i = 0; i < itemCount; i++) {
      final item = S7ParameterItem.fromBytes(bytes.sublist(offset));
      items.add(item);
      offset += item.size;
    }

    return S7Parameters(
      functionCode: functionCode,
      itemCount: itemCount,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => _$S7ParametersToJson(this);
  factory S7Parameters.fromJson(Map<String, dynamic> json) => _$S7ParametersFromJson(json);
}

/// Элемент параметра S7
@JsonSerializable()
class S7ParameterItem extends Equatable {
  /// Тип спецификации
  final int specificationType;

  /// Длина спецификации
  final int lengthOfSpecification;

  /// Спецификация
  @JsonKey(ignore: true)
  final Uint8List specification;

  const S7ParameterItem({
    required this.specificationType,
    required this.lengthOfSpecification,
    required this.specification,
  });

  @override
  List<Object?> get props => [specificationType, lengthOfSpecification, specification];

  /// Получение размера элемента
  int get size => 2 + lengthOfSpecification;

  /// Преобразование в байты
  Uint8List toBytes() {
    final bytes = Uint8List(size);
    bytes[0] = specificationType;
    bytes[1] = lengthOfSpecification;
    bytes.setRange(2, 2 + specification.length, specification);
    return bytes;
  }

  /// Создание из байтов
  static S7ParameterItem fromBytes(Uint8List bytes) {
    if (bytes.length < 2) {
      throw Exception('Invalid parameter item: too short');
    }

    final specificationType = bytes[0];
    final lengthOfSpecification = bytes[1];

    if (bytes.length < 2 + lengthOfSpecification) {
      throw Exception('Invalid parameter item: insufficient data');
    }

    final specification = bytes.sublist(2, 2 + lengthOfSpecification);

    return S7ParameterItem(
      specificationType: specificationType,
      lengthOfSpecification: lengthOfSpecification,
      specification: specification,
    );
  }

  Map<String, dynamic> toJson() => _$S7ParameterItemToJson(this);
  factory S7ParameterItem.fromJson(Map<String, dynamic> json) => _$S7ParameterItemFromJson(json);
}
