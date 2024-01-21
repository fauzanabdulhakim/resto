import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus { WiFi, Cellular, Offline, Online }

class ConnectivityProvider with ChangeNotifier {
  late Connectivity _connectivity;
  ConnectivityStatus _status = ConnectivityStatus.Offline;

  ConnectivityProvider() {
    _connectivity = Connectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _initialize();
  }

  Future<void> _initialize() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _getStatusFromResult(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _getStatusFromResult(result);
    notifyListeners();
  }

  void _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        _status = ConnectivityStatus.WiFi;
        break;
      case ConnectivityResult.mobile:
        _status = ConnectivityStatus.Cellular;
        break;
      case ConnectivityResult.none:
        _status = ConnectivityStatus.Offline;
        break;
      default:
        _status = ConnectivityStatus.Offline;
        break;
    }
  }

  bool get isConnected => _status != ConnectivityStatus.Offline;

  ConnectivityStatus get status => _status;
}
