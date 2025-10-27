import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messenger_user.g.dart';

/// Модель пользователя мессенджера
@JsonSerializable()
class MessengerUser extends Equatable {
  /// Уникальный идентификатор пользователя
  final String id;

  /// Имя пользователя
  final String username;

  /// Отображаемое имя
  final String displayName;

  /// Полное имя
  final String? fullName;

  /// E-Mail адрес
  final String? email;

  /// Номер телефона
  final String? phoneNumber;

  /// Аватар пользователя
  final String? avatarUrl;

  /// Статус пользователя
  final UserStatus status;

  /// Последняя активность
  final DateTime? lastSeen;

  /// Статусное сообщение
  final String? statusMessage;

  /// Биография/описание
  final String? bio;

  /// Местоположение
  final String? location;

  /// Веб-сайт
  final String? website;

  /// Дата рождения
  final DateTime? birthDate;

  /// Пол
  final Gender? gender;

  /// Язык
  final String? language;

  /// Часовой пояс
  final String? timezone;

  /// Является ли пользователь ботом
  final bool isBot;

  /// Является ли пользователь верифицированным
  final bool isVerified;

  /// Является ли пользователь премиум
  final bool isPremium;

  /// Настройки приватности
  final PrivacySettings privacySettings;

  /// Метаданные
  final Map<String, dynamic> metadata;

  const MessengerUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.status = UserStatus.offline,
    this.lastSeen,
    this.statusMessage,
    this.bio,
    this.location,
    this.website,
    this.birthDate,
    this.gender,
    this.language,
    this.timezone,
    this.isBot = false,
    this.isVerified = false,
    this.isPremium = false,
    this.privacySettings = const PrivacySettings(),
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        fullName,
        email,
        phoneNumber,
        avatarUrl,
        status,
        lastSeen,
        statusMessage,
        bio,
        location,
        website,
        birthDate,
        gender,
        language,
        timezone,
        isBot,
        isVerified,
        isPremium,
        privacySettings,
        metadata,
      ];

  MessengerUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    UserStatus? status,
    DateTime? lastSeen,
    String? statusMessage,
    String? bio,
    String? location,
    String? website,
    DateTime? birthDate,
    Gender? gender,
    String? language,
    String? timezone,
    bool? isBot,
    bool? isVerified,
    bool? isPremium,
    PrivacySettings? privacySettings,
    Map<String, dynamic>? metadata,
  }) {
    return MessengerUser(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      statusMessage: statusMessage ?? this.statusMessage,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      isBot: isBot ?? this.isBot,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      privacySettings: privacySettings ?? this.privacySettings,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Проверка, онлайн ли пользователь
  bool get isOnline => status == UserStatus.online;

  /// Проверка, офлайн ли пользователь
  bool get isOffline => status == UserStatus.offline;

  /// Проверка, не беспокоить ли пользователь
  bool get isAway => status == UserStatus.away;

  /// Проверка, занят ли пользователь
  bool get isBusy => status == UserStatus.busy;

  /// Проверка, невидим ли пользователь
  bool get isInvisible => status == UserStatus.invisible;

  /// Получение возраста
  int? get age {
    if (birthDate == null) return null;

    final now = DateTime.now();
    final age = now.year - birthDate!.year;

    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      return age - 1;
    }

    return age;
  }

  /// Получение времени последней активности в читаемом формате
  String? get lastSeenFormatted {
    if (lastSeen == null) return null;

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return lastSeen!.toIso8601String().split('T')[0];
    }
  }

  /// Получение статуса в читаемом формате
  String get statusString {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Away';
      case UserStatus.busy:
        return 'Busy';
      case UserStatus.invisible:
        return 'Invisible';
      case UserStatus.offline:
        return 'Offline';
    }
  }

  /// Получение полного имени для отображения
  String get displayFullName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return displayName;
  }

  /// Получение инициалов
  String get initials {
    final name = displayFullName;
    final parts = name.split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return username[0].toUpperCase();
  }

  /// Проверка, можно ли отправлять сообщения пользователю
  bool get canSendMessages {
    return !isBot && privacySettings.allowMessages;
  }

  /// Проверка, можно ли видеть статус пользователя
  bool get canSeeStatus {
    return privacySettings.showStatus;
  }

  /// Проверка, можно ли видеть последнюю активность
  bool get canSeeLastSeen {
    return privacySettings.showLastSeen;
  }

  Map<String, dynamic> toJson() => _$MessengerUserToJson(this);
  factory MessengerUser.fromJson(Map<String, dynamic> json) => _$MessengerUserFromJson(json);
}

/// Статус пользователя
enum UserStatus {
  @JsonValue('online')
  online,
  @JsonValue('away')
  away,
  @JsonValue('busy')
  busy,
  @JsonValue('invisible')
  invisible,
  @JsonValue('offline')
  offline,
}

/// Пол пользователя
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
  @JsonValue('prefer_not_to_say')
  preferNotToSay,
}

/// Настройки приватности
@JsonSerializable()
class PrivacySettings extends Equatable {
  /// Разрешить получение сообщений
  final bool allowMessages;

  /// Разрешить получение сообщений от незнакомцев
  final bool allowMessagesFromStrangers;

  /// Показывать статус
  final bool showStatus;

  /// Показывать последнюю активность
  final bool showLastSeen;

  /// Показывать статусное сообщение
  final bool showStatusMessage;

  /// Показывать аватар
  final bool showAvatar;

  /// Показывать номер телефона
  final bool showPhoneNumber;

  /// Показывать email
  final bool showEmail;

  /// Показывать местоположение
  final bool showLocation;

  /// Показывать веб-сайт
  final bool showWebsite;

  /// Разрешить добавление в группы
  final bool allowGroupInvites;

  /// Разрешить звонки
  final bool allowCalls;

  /// Разрешить видеозвонки
  final bool allowVideoCalls;

  /// Разрешить пересылку сообщений
  final bool allowMessageForwarding;

  /// Разрешить сохранение сообщений
  final bool allowMessageSaving;

  const PrivacySettings({
    this.allowMessages = true,
    this.allowMessagesFromStrangers = false,
    this.showStatus = true,
    this.showLastSeen = true,
    this.showStatusMessage = true,
    this.showAvatar = true,
    this.showPhoneNumber = false,
    this.showEmail = false,
    this.showLocation = false,
    this.showWebsite = true,
    this.allowGroupInvites = true,
    this.allowCalls = true,
    this.allowVideoCalls = true,
    this.allowMessageForwarding = true,
    this.allowMessageSaving = true,
  });

  @override
  List<Object?> get props => [
        allowMessages,
        allowMessagesFromStrangers,
        showStatus,
        showLastSeen,
        showStatusMessage,
        showAvatar,
        showPhoneNumber,
        showEmail,
        showLocation,
        showWebsite,
        allowGroupInvites,
        allowCalls,
        allowVideoCalls,
        allowMessageForwarding,
        allowMessageSaving,
      ];

  PrivacySettings copyWith({
    bool? allowMessages,
    bool? allowMessagesFromStrangers,
    bool? showStatus,
    bool? showLastSeen,
    bool? showStatusMessage,
    bool? showAvatar,
    bool? showPhoneNumber,
    bool? showEmail,
    bool? showLocation,
    bool? showWebsite,
    bool? allowGroupInvites,
    bool? allowCalls,
    bool? allowVideoCalls,
    bool? allowMessageForwarding,
    bool? allowMessageSaving,
  }) {
    return PrivacySettings(
      allowMessages: allowMessages ?? this.allowMessages,
      allowMessagesFromStrangers: allowMessagesFromStrangers ?? this.allowMessagesFromStrangers,
      showStatus: showStatus ?? this.showStatus,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      showStatusMessage: showStatusMessage ?? this.showStatusMessage,
      showAvatar: showAvatar ?? this.showAvatar,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showEmail: showEmail ?? this.showEmail,
      showLocation: showLocation ?? this.showLocation,
      showWebsite: showWebsite ?? this.showWebsite,
      allowGroupInvites: allowGroupInvites ?? this.allowGroupInvites,
      allowCalls: allowCalls ?? this.allowCalls,
      allowVideoCalls: allowVideoCalls ?? this.allowVideoCalls,
      allowMessageForwarding: allowMessageForwarding ?? this.allowMessageForwarding,
      allowMessageSaving: allowMessageSaving ?? this.allowMessageSaving,
    );
  }

  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);
  factory PrivacySettings.fromJson(Map<String, dynamic> json) => _$PrivacySettingsFromJson(json);
}
