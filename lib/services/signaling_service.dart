import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:smart_security_camera/config/app_config.dart';

typedef SignalCallback = void Function(Map<String, dynamic> data);

class SignalingService {
  WebSocketChannel? _channel;
  bool _connected = false;
  bool get connected => _connected;

  SignalCallback? onOffer;
  SignalCallback? onAnswer;
  SignalCallback? onIceCandidate;
  void Function(String role)? onPeerJoined;
  void Function(String role)? onPeerLeft;
  void Function()? onConnected;
  void Function(String)? onError;

  void connect(String cameraId, String role) {
    final uri = Uri.parse('${AppConfig.signalingUrl}?room=$cameraId&role=$role');
    print('[Signaling] Connecting to $uri (env: ${AppConfig.env})');

    try {
      _channel = WebSocketChannel.connect(uri);
      _connected = true;
      onConnected?.call();
      print('[Signaling] ✅ Connected');

      _channel!.stream.listen(
        (raw) {
          print('[Signaling] ← $raw');
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          switch (data['type']) {
            case 'offer':         onOffer?.call(data);                             break;
            case 'answer':        onAnswer?.call(data);                            break;
            case 'ice_candidate': onIceCandidate?.call(data);                     break;
            case 'peer_joined':   onPeerJoined?.call(data['role'] as String);     break;
            case 'peer_left':     onPeerLeft?.call(data['role'] as String);       break;
          }
        },
        onError: (e) {
          print('[Signaling] ❌ Error: $e');
          _connected = false;
          onError?.call('Cannot reach signaling server.\nCheck IP and port.');
        },
        onDone: () {
          print('[Signaling] Disconnected');
          _connected = false;
        },
      );
    } catch (e) {
      _connected = false;
      print('[Signaling] ❌ Connect failed: $e');
      onError?.call('Connection failed: $e');
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && _connected) {
      final json = jsonEncode(data);
      print('[Signaling] → $json');
      _channel!.sink.add(json);
    } else {
      print('[Signaling] ⚠️  Cannot send — not connected');
    }
  }

  void sendOffer(Map<String, dynamic> sdp) =>
      send({'type': 'offer', 'sdp': sdp});

  void sendAnswer(Map<String, dynamic> sdp) =>
      send({'type': 'answer', 'sdp': sdp});

  void sendIceCandidate(Map<String, dynamic> c) =>
      send({'type': 'ice_candidate', 'candidate': c});

  void disconnect() {
    _channel?.sink.close(ws_status.goingAway);
    _connected = false;
  }
}