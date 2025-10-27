// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeSettings _$ThemeSettingsFromJson(Map<String, dynamic> json) =>
    ThemeSettings(
      primaryColor:
          (json['primaryColor'] as num?)?.toInt() ?? AppColors.cyankatya,
      accentColor:
          (json['accentColor'] as num?)?.toInt() ?? AppColors.cyankatya,
      appBarColor:
          (json['appBarColor'] as num?)?.toInt() ?? AppColors.cyankatya,
      brightness: (json['brightness'] as num?)?.toInt() ?? 0,
      themeType: $enumDecodeNullable(_$ThemeTypeEnumMap, json['themeType']) ??
          ThemeType.Light,
      fontName: $enumDecodeNullable(_$FontNameEnumMap, json['fontName']) ??
          FontName.Rubik,
      fontSize: $enumDecodeNullable(_$FontSizeEnumMap, json['fontSize']) ??
          FontSize.Default,
      messageSize:
          $enumDecodeNullable(_$MessageSizeEnumMap, json['messageSize']) ??
              MessageSize.Default,
      avatarShape:
          $enumDecodeNullable(_$AvatarShapeEnumMap, json['avatarShape']) ??
              AvatarShape.Circle,
      mainFabType:
          $enumDecodeNullable(_$MainFabTypeEnumMap, json['mainFabType']) ??
              MainFabType.Ring,
      mainFabLabel:
          $enumDecodeNullable(_$MainFabLabelEnumMap, json['mainFabLabel']) ??
              MainFabLabel.Off,
      mainFabLocation: $enumDecodeNullable(
              _$MainFabLocationEnumMap, json['mainFabLocation']) ??
          MainFabLocation.Right,
    );

Map<String, dynamic> _$ThemeSettingsToJson(ThemeSettings instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
      'appBarColor': instance.appBarColor,
      'brightness': instance.brightness,
      'themeType': _$ThemeTypeEnumMap[instance.themeType]!,
      'fontName': _$FontNameEnumMap[instance.fontName]!,
      'fontSize': _$FontSizeEnumMap[instance.fontSize]!,
      'messageSize': _$MessageSizeEnumMap[instance.messageSize]!,
      'avatarShape': _$AvatarShapeEnumMap[instance.avatarShape]!,
      'mainFabType': _$MainFabTypeEnumMap[instance.mainFabType]!,
      'mainFabLabel': _$MainFabLabelEnumMap[instance.mainFabLabel]!,
      'mainFabLocation': _$MainFabLocationEnumMap[instance.mainFabLocation]!,
    };

const _$ThemeTypeEnumMap = {
  ThemeType.Light: 'Light',
  ThemeType.Dark: 'Dark',
  ThemeType.Darker: 'Darker',
  ThemeType.Night: 'Night',
  ThemeType.System: 'System',
};

const _$FontNameEnumMap = {
  FontName.Rubik: 'Rubik',
  FontName.Roboto: 'Roboto',
  FontName.Poppins: 'Poppins',
  FontName.Inter: 'Inter',
};

const _$FontSizeEnumMap = {
  FontSize.Small: 'Small',
  FontSize.Default: 'Default',
  FontSize.Large: 'Large',
};

const _$MessageSizeEnumMap = {
  MessageSize.Small: 'Small',
  MessageSize.Default: 'Default',
  MessageSize.Large: 'Large',
};

const _$AvatarShapeEnumMap = {
  AvatarShape.Circle: 'Circle',
  AvatarShape.Square: 'Square',
};

const _$MainFabTypeEnumMap = {
  MainFabType.Ring: 'Ring',
  MainFabType.Bar: 'Bar',
};

const _$MainFabLabelEnumMap = {
  MainFabLabel.On: 'On',
  MainFabLabel.Off: 'Off',
};

const _$MainFabLocationEnumMap = {
  MainFabLocation.Right: 'Right',
  MainFabLocation.Left: 'Left',
};
