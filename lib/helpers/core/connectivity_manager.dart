import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionType {
  wifi,
  mobile,
  vpn,
  bluetooth,
  other,
  none,
}

// Note for iOS and macOS:
// There is no separate network interface type for [vpn].
// It returns [other] on any device (also simulator)

class ConnectivityManager {
  ConnectivityManager() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  final _connectionTypeController =
      StreamController<ConnectionType>.broadcast();

  Stream<ConnectionType> get connectionType => _connectionTypeController.stream;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      _connectionTypeController.sink.add(ConnectionType.mobile);
    } else if (results.contains(ConnectivityResult.wifi)) {
      _connectionTypeController.sink.add(ConnectionType.wifi);
    } else {
      _connectionTypeController.sink.add(ConnectionType.none);
    }
  }

  Future<String> getConnectionTypeAsString() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return 'mobile';
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return 'wifi';
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return 'vpn';
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return 'bluetooth';
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      return 'other';
    }
    return 'none';
  }

  void dispose() {
    _connectionTypeController.close();
    _connectivitySubscription?.cancel();
  }
}
