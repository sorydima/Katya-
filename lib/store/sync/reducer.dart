import './actions.dart';
import './state.dart';

SyncStore syncReducer([SyncStore state = const SyncStore(), dynamic action]) {
  switch (action.runtimeType) {
    case SetSyncing:
      final action0 = action as SetSyncing;
      return state.copyWith(
        syncing: action0.syncing,
        lastAttempt: DateTime.now().millisecondsSinceEpoch,
      );
    case SetBackoff:
      final action0 = action as SetBackoff;
      return state.copyWith(
        backoff: action0.backoff,
      );
    case SetUnauthed:
      final action0 = action as SetUnauthed;
      return state.copyWith(
        unauthed: action0.unauthed,
      );
    case SetBackgrounded:
      final action0 = action as SetBackgrounded;
      return state.copyWith(
        backgrounded: action0.backgrounded,
      );
    case SetOffline:
      final action0 = action as SetOffline;
      return state.copyWith(
        offline: action0.offline,
      );
    case SetSynced:
      final action0 = action as SetSynced;
      return state.copyWith(
        backoff: 0,
        offline: false,
        synced: action0.synced,
        syncing: action0.syncing,
        lastSince: action0.lastSince,
        lastAttempt: DateTime.now().millisecondsSinceEpoch,
        lastUpdate: action0.synced ?? false ? DateTime.now().millisecondsSinceEpoch : state.lastUpdate,
      );
    case SetSyncObserver:
      final action0 = action as SetSyncObserver;
      return state.copyWith(
        syncObserver: action0.syncObserver,
      );
    case ResetSync:
      return const SyncStore();
    default:
      return state;
  }
}
