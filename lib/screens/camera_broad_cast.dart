import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_security_camera/controllers/recording_controller.dart';
import 'package:smart_security_camera/screens/live_view.dart';
import '../services/webrtc_service.dart';

class CameraBroadcastScreen extends StatefulWidget {
  const CameraBroadcastScreen({super.key});
  @override
  State<CameraBroadcastScreen> createState() => _CameraBroadcastScreenState();
}

class _CameraBroadcastScreenState extends State<CameraBroadcastScreen>
    with WidgetsBindingObserver {
  final WebRTCService _webrtc = WebRTCService();

  bool   _broadcasting  = false;
  bool   _muted         = false;
  bool   _videoOff      = false;
  bool   _permGranted   = false;
  bool   _checking      = true;
  String _status        = 'Checking permissions…';

  static const _cameraName = 'My Camera';

  static const String _cameraId = 'cam_001'; // match viewer's cameraId

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestPermissions();
  }

  // ── Step 1: Request camera + mic permissions ──────────────
  Future<void> _checkAndRequestPermissions() async {
    setState(() { _checking = true; _status = 'Requesting permissions…'; });

    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    print('[Permission] Camera: $camStatus');
    print('[Permission] Microphone: $micStatus');

    if (camStatus.isGranted && micStatus.isGranted) {
      setState(() { _permGranted = true; _checking = false; _status = 'Ready to broadcast'; });
      // Auto-init renderer after permission granted
      await _initRenderer();
    } else if (camStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      setState(() {
        _checking = false;
        _status = 'Permission permanently denied.\nPlease enable in Settings.';
      });
    } else {
      setState(() {
        _checking = false;
        _status = 'Camera/Mic permission denied.';
      });
    }
  }

  // ── Step 2: Init renderer (after permission) ──────────────
  Future<void> _initRenderer() async {
    await _webrtc.initialize();
    // Show local preview immediately
    try {
      final stream = await rtc.navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'environment'},
      });
      _webrtc.localRenderer.srcObject = stream;
      if (mounted) setState(() {});
      print('[Camera] Local preview started');
    } catch (e) {
      print('[Camera] Preview error: $e');
      setState(() => _status = 'Camera error: $e');
    }
  }

  // ── Step 3: Start broadcasting ────────────────────────────
  Future<void> _startBroadcast() async {
    setState(() { _broadcasting = true; _status = 'Starting broadcast…'; });

    _webrtc.onStatusChanged = (msg) {
      if (mounted) setState(() => _status = msg);
    };

    _webrtc.onConnectionStateChange = (state) {
      if (!mounted) return;
      setState(() {
        switch (state) {
          case rtc.RTCIceConnectionState.RTCIceConnectionStateConnected:
          case rtc.RTCIceConnectionState.RTCIceConnectionStateCompleted:
            _status = '✅ Viewer watching live'; break;
          case rtc.RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            _status = 'Viewer disconnected'; break;
          case rtc.RTCIceConnectionState.RTCIceConnectionStateFailed:
            _status = 'Connection failed'; _broadcasting = false; break;
          default: break;
        }
      });
    };

    _webrtc.onError = (e) {
      if (mounted) setState(() { _status = '❌ $e'; _broadcasting = false; });
    };

    await _webrtc.startBroadcast(
      cameraId:    _cameraId,
      frontCamera: false,
      audioEnabled: !_muted, userId: '',
    );
  }

  Future<void> _stopBroadcast() async {
    await _webrtc.dispose();
    await _initRenderer(); // restart preview
    if (mounted) setState(() { _broadcasting = false; _status = 'Ready to broadcast'; });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.paused   && _broadcasting) _webrtc.toggleVideo(true);
    if (s == AppLifecycleState.resumed  && _broadcasting) _webrtc.toggleVideo(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webrtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green  = Color(0xFF00E5A0);
    const red    = Color(0xFFFF4D4D);
    const surf   = Color(0xFF161B22);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Camera Mode'),
        actions: [
          if (_broadcasting)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(8)),
              child: const Text('● ON AIR',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          // ── Camera preview ──────────────────────────────
          Expanded(
            child: Stack(children: [
              // Show preview only if permission granted & renderer ready
              if (_permGranted && _webrtc.isInitialized)
                rtc.RTCVideoView(
                  _webrtc.localRenderer,
                  mirror: false,
                  objectFit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              else
                Container(
                  color: const Color(0xFF0D1117),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (_checking)
                        const CircularProgressIndicator(color: green, strokeWidth: 2)
                      else
                        Icon(
                          _permGranted ? Icons.videocam : Icons.no_photography,
                          color: _permGranted ? green : red,
                          size: 52,
                        ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      // If permanently denied → open Settings button
                      if (_status.contains('Settings')) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: openAppSettings,
                          style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black),
                          child: const Text('Open Settings'),
                        ),
                      ],
                      // If just denied → retry button
                      if (_status.contains('denied') && !_status.contains('Settings')) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _checkAndRequestPermissions,
                          icon: const Icon(Icons.refresh, color: green),
                          label: const Text('Retry', style: TextStyle(color: green)),
                        ),
                      ],
                    ]),
                  ),
                ),
              // Status chip overlay
              if (_permGranted)
                Positioned(
                  bottom: 12, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_status, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                ),
            ]),
          ),

          // ── Controls ────────────────────────────────────
          Container(
            color: surf,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(children: [
              Obx(() {
                final recCtrl   = RecordingController.to;
                final isRec     = recCtrl.isRecording;
                final isUpl     = recCtrl.isUploading;
                return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Btn(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? 'Unmute' : 'Mute',
                    color: _muted ? red : Colors.white,
                    onTap: _permGranted ? () {
                      setState(() => _muted = !_muted);
                      _webrtc.toggleMute(_muted);
                    } : null,
                  ),
                  Btn(
                    icon: _videoOff ? Icons.videocam_off : Icons.videocam,
                    label: _videoOff ? 'Video Off' : 'Video On',
                    color: _videoOff ? red : Colors.white,
                    onTap: _permGranted ? () {
                      setState(() => _videoOff = !_videoOff);
                      _webrtc.toggleVideo(_videoOff);
                    } : null,
                  ),
                  Btn(
                    icon: Icons.flip_camera_android,
                    label: 'Flip',
                    onTap: _permGranted ? _webrtc.switchCamera : null,
                  ),
                  // Record button — only active while broadcasting
                  if (isUpl)
                    Btn(icon: Icons.cloud_upload, label: 'Saving…', color: const Color(0xFFFFB300))
                  else
                    Btn(
                      icon: isRec ? Icons.stop_circle_outlined : Icons.fiber_manual_record,
                      label: isRec ? 'Stop Rec' : 'Record',
                      color: isRec ? red : Colors.white,
                      onTap: _broadcasting && _permGranted
                          ? () async {
                              if (isRec) {
                                await RecordingController.to.stopRecording(
                                  cameraId:   _cameraId,
                                  cameraName: _cameraName,
                                );
                              } else {
                                final stream = _webrtc.localStream;
                                if (stream != null) {
                                  await RecordingController.to.startRecording(stream);
                                }
                              }
                            }
                          : null,
                    ),
                ]);
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Disable button if permission not granted
                  onPressed: _permGranted
                      ? (_broadcasting ? _stopBroadcast : _startBroadcast)
                      : _checkAndRequestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_permGranted
                        ? Colors.grey
                        : _broadcasting ? red : green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    !_permGranted
                        ? 'Grant Camera Permission'
                        : _broadcasting ? 'Stop Broadcasting' : 'Start Broadcasting',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}