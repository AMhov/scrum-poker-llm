import 'dart:async';

import '../services/api_service.dart';
import '../services/socket_service.dart';

class ConnectionStatus {
  final ApiService apiService;
  final SocketService socketService;

  bool _apiConnected = false;
  Timer? _pingTimer;

  bool get isConnected => _apiConnected && socketService.isConnected;
  bool get apiConnected => _apiConnected;
  bool get socketConnected => socketService.isConnected;

  ConnectionStatus({
    required this.apiService,
    required this.socketService,
  }) {
    _startMonitoring();
  }

  void _startMonitoring() {
    // Периодическая проверка API
    _pingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      _apiConnected = await _pingApi();
    });

    // Первая проверка сразу
    _pingApi();
  }

  Future<bool> _pingApi() async {
    try {
      return await apiService.ping();
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _pingTimer?.cancel();
  }
}
