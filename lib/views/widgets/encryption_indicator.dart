import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:katya/store/index.dart';
import 'package:katya/store/rooms/selectors.dart';
import 'package:redux/redux.dart';

class EncryptionIndicator extends StatelessWidget {
  final String roomId;
  final double size;
  final Color? color;

  const EncryptionIndicator({
    super.key,
    required this.roomId,
    this.size = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) => _Props.mapStateToProps(store, roomId),
      builder: (context, props) {
        if (!props.isEncrypted) return const SizedBox.shrink();

        return Tooltip(
          message: 'End-to-end encrypted',
          child: Icon(
            Icons.lock_outline,
            size: size,
            color: color ?? Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }
}

class _Props {
  final bool isEncrypted;
  final bool isVerified;

  const _Props({
    required this.isEncrypted,
    required this.isVerified,
  });

  static _Props mapStateToProps(Store<AppState> store, String roomId) => _Props(
        isEncrypted: selectIsRoomEncrypted(store.state, roomId),
        isVerified: selectIsRoomVerified(store.state, roomId),
      );
}
