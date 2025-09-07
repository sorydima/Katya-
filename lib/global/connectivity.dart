import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static ConnectivityResult? lastStatus;
  static ConnectivityResult? currentStatus;
  static StreamSubscription<List<ConnectivityResult>>? connectivity;

  static bool isConnected() {
    return currentStatus != null && currentStatus != ConnectivityResult.none;
  }

  static Future startListener() async {
    if (connectivity != null) return;

    final statuses = await Connectivity().checkConnectivity();
    currentStatus = statuses.isNotEmpty ? statuses.first : ConnectivityResult.none;

    return connectivity = Connectivity().onConnectivityChanged.listen((results) {
      currentStatus = results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  static Future<void> stopListener() async {
    if (connectivity != null) {
      await connectivity?.cancel();
      connectivity = null;
    }
  }
}
