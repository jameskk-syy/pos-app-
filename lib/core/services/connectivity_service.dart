import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetConnectionChecker =
      InternetConnectionChecker();

  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  bool _hasConnection = false;
  bool get hasConnection => _hasConnection;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    // Use the first result if it's a list, assuming single interface relevance for now
    ConnectivityResult result = results.isNotEmpty
        ? results.first
        : ConnectivityResult.none;
    _checkConnection(result);
  }

  void _connectionChange(List<ConnectivityResult> results) {
    ConnectivityResult result = results.isNotEmpty
        ? results.first
        : ConnectivityResult.none;
    _checkConnection(result);
  }

  Future<void> _checkConnection(ConnectivityResult result) async {
    bool previousConnection = _hasConnection;

    if (result == ConnectivityResult.none) {
      _hasConnection = false;
    } else {
      // Actually check if we have internet access
      try {
        _hasConnection = await _internetConnectionChecker.hasConnection.timeout(
          const Duration(seconds: 3),
        );
      } catch (e) {
        _hasConnection = false;
      }
    }

    if (previousConnection != _hasConnection) {
      _connectionChangeController.add(_hasConnection);
    }
  }

  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    await _checkConnection(result);
    return _hasConnection;
  }

  void dispose() {
    _connectionChangeController.close();
  }
}
