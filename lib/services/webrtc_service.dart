import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling_service.dart';

class WebRTCService {
  final SignalingService signaling = SignalingService();

  RTCPeerConnection? _pc;
  MediaStream?       _localStream;
  MediaStream?       _remoteStream;

  final RTCVideoRenderer localRenderer  = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool get isInitialized => _initialized;
  bool _initialized = false;

  MediaStream? get localStream => _localStream;

  void Function(MediaStream)?          onRemoteStream;
  void Function(RTCIceConnectionState)? onConnectionStateChange;
  void Function(String)?               onError;
  void Function(String)?               onStatusChanged;

  // ── STUN servers (free, no setup needed) ─────────────────
  static const Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _initialized = true;
    print('[WebRTC] Renderers initialized');
  }

  Future<void> _createPC() async {
    _pc = await createPeerConnection(_iceConfig);
    print('[WebRTC] PeerConnection created');

    _pc!.onIceCandidate = (c) {
      if (c.candidate != null) {
        print('[WebRTC] ICE candidate: ${c.candidate}');
        signaling.sendIceCandidate({
          'candidate':     c.candidate,
          'sdpMid':        c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        });
      }
    };

    _pc!.onIceConnectionState = (state) {
      print('[WebRTC] ICE state: $state');
      onConnectionStateChange?.call(state);
    };

    _pc!.onConnectionState = (state) {
      print('[WebRTC] Connection state: $state');
    };

    _pc!.onTrack = (event) {
      print('[WebRTC] Remote track received: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
        onRemoteStream?.call(_remoteStream!);
      }
    };
  }

  // ── BROADCASTER (old phone / camera device) ───────────────
  Future<void> startBroadcast({
    required String cameraId,
    bool frontCamera   = false,
    bool audioEnabled  = true, required String userId,
  }) async {
    try {
      onStatusChanged?.call('Opening camera…');
      await _createPC();

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': audioEnabled,
        'video': {
          'facingMode': frontCamera ? 'user' : 'environment',
          'width':      {'ideal': 1280},
          'height':     {'ideal': 720},
        },
      });

      localRenderer.srcObject = _localStream;
      _localStream!.getTracks().forEach((t) {
        _pc!.addTrack(t, _localStream!);
        print('[WebRTC] Added track: ${t.kind}');
      });

      onStatusChanged?.call('Waiting for viewer to connect…');

      // Connect signaling as broadcaster
      signaling.connect(cameraId, 'broadcaster');

      // When viewer joins → create and send offer
      signaling.onPeerJoined = (role) async {
        if (role == 'viewer') {
          print('[WebRTC] Viewer joined — creating offer');
          onStatusChanged?.call('Viewer connected — setting up stream…');
          final offer = await _pc!.createOffer({
            'offerToReceiveAudio': false,
            'offerToReceiveVideo': false,
          });
          await _pc!.setLocalDescription(offer);
          signaling.sendOffer({'type': offer.type, 'sdp': offer.sdp});
        }
      };

      signaling.onAnswer = (data) async {
        print('[WebRTC] Got answer from viewer');
        onStatusChanged?.call('Establishing connection…');
        await _pc!.setRemoteDescription(RTCSessionDescription(
          data['sdp']['sdp'] as String,
          data['sdp']['type'] as String,
        ));
      };

      _listenForIce();

      signaling.onError = (e) {
        onStatusChanged?.call('Signaling error: $e');
        onError?.call(e);
      };
    } catch (e) {
      print('[WebRTC] Broadcast error: $e');
      onError?.call(e.toString());
    }
  }

  // ── VIEWER (owner's phone) ────────────────────────────────
  Future<void> startViewing({required String cameraId}) async {
    try {
      onStatusChanged?.call('Connecting to signaling server…');
      await _createPC();

      signaling.connect(cameraId, 'viewer');

      signaling.onConnected = () {
        onStatusChanged?.call('Connected — waiting for camera…');
        print('[WebRTC] Signaling connected as viewer');
      };

      // Receive offer from broadcaster
      signaling.onOffer = (data) async {
        print('[WebRTC] Got offer from broadcaster');
        onStatusChanged?.call('Camera found — connecting…');

        await _pc!.setRemoteDescription(RTCSessionDescription(
          data['sdp']['sdp'] as String,
          data['sdp']['type'] as String,
        ));

        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);
        signaling.sendAnswer({'type': answer.type, 'sdp': answer.sdp});
        print('[WebRTC] Answer sent');
      };

      _listenForIce();

      signaling.onError = (e) {
        onStatusChanged?.call('❌ $e');
        onError?.call(e);
      };

      signaling.onPeerLeft = (role) {
        if (role == 'broadcaster') onStatusChanged?.call('Camera disconnected');
      };
    } catch (e) {
      print('[WebRTC] Viewer error: $e');
      onError?.call(e.toString());
    }
  }

  void _listenForIce() {
    signaling.onIceCandidate = (data) async {
      try {
        final c = data['candidate'] as Map<String, dynamic>;
        await _pc!.addCandidate(RTCIceCandidate(
          c['candidate']     as String,
          c['sdpMid']        as String?,
          c['sdpMLineIndex'] as int?,
        ));
        print('[WebRTC] ICE candidate added');
      } catch (e) {
        print('[WebRTC] ICE add error: $e');
      }
    };
  }

  // ── Broadcaster controls ──────────────────────────────────
  void toggleMute(bool mute) =>
      _localStream?.getAudioTracks().forEach((t) => t.enabled = !mute);

  void toggleVideo(bool off) =>
      _localStream?.getVideoTracks().forEach((t) => t.enabled = !off);

  // ── Viewer controls ───────────────────────────────────────
  /// Mute / unmute the incoming audio on the viewer side.
  void toggleRemoteAudio(bool mute) =>
      _remoteStream?.getAudioTracks().forEach((t) => t.enabled = !mute);

  Future<void> switchCamera() async {
    final t = _localStream?.getVideoTracks().firstOrNull;
    if (t != null) await Helper.switchCamera(t);
  }

  Future<void> dispose() async {
  signaling.disconnect();

  _localStream?.getTracks().forEach((t) => t.stop());
  await _localStream?.dispose();
  _localStream = null;

  await _pc?.close();
  _pc = null;

  // ✅ Only clear srcObject if renderers are still initialized
  if (_initialized) {
    try {
      localRenderer.srcObject  = null;
      remoteRenderer.srcObject = null;
    } catch (e) {
      print('[WebRTC] srcObject clear skipped: $e');
    }
  }

  // ✅ Dispose renderers last
  await localRenderer.dispose();
  await remoteRenderer.dispose();

  _initialized = false;
  print('[WebRTC] Disposed');
}
}
