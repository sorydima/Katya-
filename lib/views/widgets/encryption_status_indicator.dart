import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/global/colors.dart';
import 'package:katya/l10n/l10n.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/room/model.dart';

class EncryptionStatusIndicator extends StatelessWidget {
  final Room room;
  final bool showLabel;
  final double size;

  const EncryptionStatusIndicator({
    super.key,
    required this.room,
    this.showLabel = false,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);

    if (!room.encryptionEnabled) {
      return const SizedBox.shrink();
    }

    final isVerified = room.verificationState == 'verified';
    final color = isVerified ? Colors.green : Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: isVerified
          ? l10n.encryptionVerified
          : room.encryptionEnabled
              ? l10n.encryptionEnabled
              : l10n.encryptionDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                isVerified ? Icons.verified_user : Icons.lock_outline,
                size: size,
                color: color,
              ),
              if (isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: size * 0.6,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              isVerified ? l10n.encryptionVerified : l10n.encryptionEnabled,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget withStore({
    required BuildContext context,
    required String roomId,
    bool showLabel = false,
    double size = 16.0,
  }) {
    return StoreConnector<AppState, Room?>(
      distinct: true,
      converter: (Store<AppState> store) => store.state.roomStore.rooms[roomId],
      builder: (context, room) {
        if (room == null) return const SizedBox.shrink();
        return EncryptionStatusIndicator(
          room: room,
          showLabel: showLabel,
          size: size,
        );
      },
    );
  }

  static Widget small({required Room room}) {
    return EncryptionStatusIndicator(
      room: room,
      size: 12.0,
      showLabel: false,
    );
  }

  static Widget medium({required Room room, bool showLabel = true}) {
    return EncryptionStatusIndicator(
      room: room,
      size: 16.0,
      showLabel: showLabel,
    );
  }

  static Widget large({required Room room, bool showLabel = true}) {
    return EncryptionStatusIndicator(
      room: room,
      size: 20.0,
      showLabel: showLabel,
    );
  }
}
