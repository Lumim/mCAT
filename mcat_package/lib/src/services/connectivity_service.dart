import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub; // Fixed type

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void startListening(Function onConnected) {
    _sub = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      // Fixed parameter type
      if (results.any((result) => result != ConnectivityResult.none)) {
        onConnected();
      }
    });
  }

  void dispose() => _sub?.cancel();
}
