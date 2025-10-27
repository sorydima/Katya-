import 'dart:typed_data';

import 'package:katya/store/media/model.dart';

import './actions.dart';
import './state.dart';

MediaStore mediaReducer([MediaStore state = const MediaStore(), dynamic action]) {
  switch (action.runtimeType) {
    case UpdateMediaCache:
      final action0 = action as UpdateMediaCache;

      final data = action0.data;
      final mxcUri = action0.mxcUri!;

      final medias = Map<String, Media>.from(state.media);
      final mediaCache = Map<String, Uint8List>.from(state.mediaCache);

      // Update media cache data
      if (data != null) {
        mediaCache[mxcUri] = data;
      }

      medias.putIfAbsent(
        mxcUri,
        () => Media(
          mxcUri: action0.mxcUri,
          info: action0.info,
          type: action0.type,
          // data: _action.data TODO: pull only from the media object itself
        ),
      );

      medias.update(
        mxcUri,
        (value) => Media(
          mxcUri: action0.mxcUri,
          info: value.info ?? action0.info,
          type: action0.type,
          // data: _action.data TODO: pull only from the media object itself
        ),
      );

      return state.copyWith(
        media: medias,
        mediaCache: mediaCache,
      );
    case UpdateMediaChecks:
      final action0 = action as UpdateMediaChecks;
      final mediaChecks = Map<String, String>.from(state.mediaStatus);
      // ignore: cast_nullable_to_non_nullable
      mediaChecks[action0.mxcUri!] = (action0.status as MediaStatus).value;
      return state.copyWith(
        mediaStatus: mediaChecks,
      );
    default:
      return state;
  }
}
