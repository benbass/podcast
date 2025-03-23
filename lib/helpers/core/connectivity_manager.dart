import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionType {
  wifi,
  mobile,
  none,
}

class ConnectivityManager {
  static final ConnectivityManager _connectivityManager = ConnectivityManager._internal();
  ConnectivityManager._internal() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  factory ConnectivityManager() {
    return _connectivityManager;
  }

  final _connectionTypeController =
  StreamController<ConnectionType>.broadcast();

  Stream<ConnectionType> get connectionType =>
      _connectionTypeController.stream;

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

  void dispose() {
    _connectionTypeController.close();
    _connectivitySubscription?.cancel();
  }
}