import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  static Stream<bool> get connectionStream => _connectionController.stream;

  static void initialize() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      bool isConnected = results.any((result) => result != ConnectivityResult.none);
      _connectionController.add(isConnected);
    });
  }

  static Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static void dispose() {
    _connectionController.close();
  }
}