import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/webrtc_service.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key});
  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  late WebRTCService _webrtc;
  bool _connected = false;
  bool _audioMuted = false;
  bool _mirrored   = false;
  String _status = 'Starting…';
  RTCIceConnectionState _iceState = RTCIceConnectionState.RTCIceConnectionStateNew;

  String get _camId => ModalRoute.of(context)?.settings.arguments as String? ?? 'cam_001';

  // Read cameraId from route arguments

  @override
  void initState() {
    super.initState();
    _webrtc = WebRTCService(); // ✅ create here

    _start();
  }

  Future<void> _start() async {
    print('>>> LiveViewScreen: starting as VIEWER for room $_camId');
    await _webrtc.initialize();

    _webrtc.onStatusChanged = (msg) {
      if (mounted) setState(() => _status = msg);
    };

    _webrtc.onRemoteStream = (_) {
      if (mounted) {
        setState(() {
          _connected = true;
          _status = 'Live';
        });
      }
    };

    _webrtc.onConnectionStateChange = (s) {
      if (!mounted) return;
      setState(() {
        _iceState = s;
        switch (s) {
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            _connected = true;
            _status = 'Live';
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            _connected = false;
            _status = 'Reconnecting…';
            break;
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            _connected = false;
            _status = '❌ Failed — tap Reconnect';
            break;
          default:
            break;
        }
      });
    };

    _webrtc.onError = (e) {
      if (mounted) setState(() => _status = '❌ $e');
    };

    await _webrtc.startViewing(cameraId: _camId);
  }

  Future<void> _reconnect() async {
    setState(() {
      _connected = false;
      _status = 'Reconnecting…';
    });

    // ✅ Safely dispose old service
    try {
      await _webrtc.dispose();
    } catch (e) {
      print('[Reconnect] dispose error (ignored): $e');
    }

    // ✅ Create a FRESH WebRTCService — do not reuse old one
    _webrtc = WebRTCService();

    // ✅ Start fresh
    await _start();
  }

  @override
  void dispose() {
    _webrtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00E5A0);
    const red = Color(0xFFFF4D4D);
    const surf = Color(0xFF161B22);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: _connected ? red : Colors.grey),
            ),
            Flexible(
              child: Text(
                _connected ? 'LIVE' : _status,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: _connected ? Colors.white : Colors.grey,
                  fontWeight: _connected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // ── Remote video output ───────────────────────
                  RTCVideoView(
                    _webrtc.remoteRenderer,
                    mirror: _mirrored,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  ),
                  // ── Waiting overlay ───────────────────────────
                  if (!_connected)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: green, strokeWidth: 2),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _status,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: _reconnect,
                              icon: const Icon(Icons.refresh, color: green),
                              label: const Text('Reconnect', style: TextStyle(color: green)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // ── LIVE badge ────────────────────────────────
                  if (_connected)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(6)),
                        child: const Text(
                          '● LIVE',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  // ── ICE state debug ───────────────────────────
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _iceState.toString().replaceAll('RTCIceConnectionState.RTCIceConnectionState', ''),
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: surf,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Audio mute / unmute
                  Btn(
                    icon: _audioMuted ? Icons.volume_off : Icons.volume_up,
                    label: _audioMuted ? 'Unmute' : 'Audio',
                    color: _audioMuted ? red : null,
                    onTap: () {
                      setState(() => _audioMuted = !_audioMuted);
                      _webrtc.toggleRemoteAudio(_audioMuted);
                    },
                  ),
                  // Mirror / flip video
                  Btn(
                    icon: Icons.flip,
                    label: _mirrored ? 'Flip On' : 'Flip Off',
                    color: _mirrored ? green : null,
                    onTap: () => setState(() => _mirrored = !_mirrored),
                  ),
                  // Reconnect
                  Btn(
                    icon: Icons.refresh,
                    label: 'Reconnect',
                    onTap: _reconnect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  const Btn({super.key, required this.icon, required this.label, this.color, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color ?? Colors.white54, fontSize: 11)),
      ],
    ),
  );
}
