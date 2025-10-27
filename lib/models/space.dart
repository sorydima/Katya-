import 'package:equatable/equatable.dart';
import 'package:matrix/matrix.dart';

class Space extends Equatable {
  final String id;
  final String? name;
  final String? topic;
  final String? avatarUrl;
  final List<String> roomIds;
  final List<String> childSpaceIds;
  final bool isPublic;
  final Map<String, dynamic>? viaServers;
  final Map<String, dynamic>? spaceContent;
  final int? creationTime;
  final int? lastActiveTime;
  final bool isEncrypted;
  final String? encryptionAlgorithm;

  const Space({
    required this.id,
    this.name,
    this.topic,
    this.avatarUrl,
    this.roomIds = const [],
    this.childSpaceIds = const [],
    this.isPublic = false,
    this.viaServers,
    this.spaceContent,
    this.creationTime,
    this.lastActiveTime,
    this.isEncrypted = false,
    this.encryptionAlgorithm,
  });

  factory Space.fromMatrixRoom(Room room) {
    return Space(
      id: room.id,
      name: room.name,
      topic: room.topic,
      avatarUrl: room.avatar?.url.toString(),
      roomIds: room.spaceChildren
          .where((child) => child.roomType != 'm.space')
          .map((child) => child.roomId)
          .toList(),
      childSpaceIds: room.spaceChildren
          .where((child) => child.roomType == 'm.space')
          .map((child) => child.roomId)
          .toList(),
      isPublic: room.joinRules == JoinRules.public,
      viaServers: room.viaServers,
      spaceContent: room.spaceContent,
      creationTime: room.creationTime,
      lastActiveTime: room.lastEvent?.originServerTs,
      isEncrypted: room.encrypted,
      encryptionAlgorithm: room.encryptionAlgorithm,
    );
  }

  Space copyWith({
    String? id,
    String? name,
    String? topic,
    String? avatarUrl,
    List<String>? roomIds,
    List<String>? childSpaceIds,
    bool? isPublic,
    Map<String, dynamic>? viaServers,
    Map<String, dynamic>? spaceContent,
    int? creationTime,
    int? lastActiveTime,
    bool? isEncrypted,
    String? encryptionAlgorithm,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roomIds: roomIds ?? this.roomIds,
      childSpaceIds: childSpaceIds ?? this.childSpaceIds,
      isPublic: isPublic ?? this.isPublic,
      viaServers: viaServers ?? this.viaServers,
      spaceContent: spaceContent ?? this.spaceContent,
      creationTime: creationTime ?? this.creationTime,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encryptionAlgorithm: encryptionAlgorithm ?? this.encryptionAlgorithm,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        topic,
        avatarUrl,
        roomIds,
        childSpaceIds,
        isPublic,
        viaServers,
        spaceContent,
        creationTime,
        lastActiveTime,
        isEncrypted,
        encryptionAlgorithm,
      ];
}
