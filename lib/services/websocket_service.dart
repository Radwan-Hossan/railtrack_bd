import 'dart:async';
import 'dart:math';

enum WebSocketConnectionState {
  connecting,
  connected,
  reconnecting,
  disconnected,
}

class WebSocketService {
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  Timer? _heartbeatTimer;
  final StreamController<Map<String, dynamic>> _trainUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  WebSocketConnectionState get connectionState => _connectionState;
  Stream<Map<String, dynamic>> get stream => _trainUpdateController.stream;

  void connect({String serverUrl = 'wss://api.railtrack.bd/v1/telemetry'}) {
    _connectionState = WebSocketConnectionState.connecting;
    
    // Simulate real WebSocket handshake and persistent channel
    Future.delayed(const Duration(milliseconds: 600), () {
      _connectionState = WebSocketConnectionState.connected;
      _startHeartbeat();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_connectionState == WebSocketConnectionState.connected) {
        // Emit live telemetry message packet
        final jitter = (Random().nextDouble() - 0.5) * 0.001;
        _trainUpdateController.add({
          'type': 'TELEMETRY_UPDATE',
          'timestamp': DateTime.now().toIso8601String(),
          'signalQuality': 'EXCELLENT',
          'activeSatellites': 9,
          'jitterLat': jitter,
          'jitterLng': jitter,
        });
      }
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _connectionState = WebSocketConnectionState.disconnected;
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _trainUpdateController.close();
  }
}
