import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_security_camera/model/recording_model.dart';

class RecordingService {
  RecordingService._();
  static final RecordingService instance = RecordingService._();

  final _firestore = FirebaseFirestore.instance;
  final _storage   = FirebaseStorage.instance;
  final _uuid      = const Uuid();

  MediaRecorder? _recorder;
  DateTime?      _startTime;
  String?        _localPath;

  bool get isRecording => _recorder != null;

  // ── Start recording ───────────────────────────────────────
  Future<void> startRecording(MediaStream stream) async {
    if (_recorder != null) return;

    final dir  = await getTemporaryDirectory();
    _localPath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.mp4';

    _recorder  = MediaRecorder();
    _startTime = DateTime.now();

    final videoTrack = stream.getVideoTracks().isNotEmpty
        ? stream.getVideoTracks().first
        : null;

    await _recorder!.start(
      _localPath!,
      videoTrack:   videoTrack,
      audioChannel: RecorderAudioChannel.INPUT,
    );
    debugPrint('[Recording] Started → $_localPath');
  }

  // ── Stop, upload, save metadata ───────────────────────────
  /// Returns the saved [RecordingModel] on success, null on error.
  Future<RecordingModel?> stopAndSave({
    required String cameraId,
    required String cameraName,
  }) async {
    if (_recorder == null || _localPath == null || _startTime == null) return null;

    try {
      await _recorder!.stop();
      _recorder = null;

      final file     = File(_localPath!);
      final duration = DateTime.now().difference(_startTime!).inSeconds;
      final fileSize = await file.length();
      final userId   = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final recId    = _uuid.v4();

      debugPrint('[Recording] Stopped. Duration: ${duration}s  Size: $fileSize bytes');

      // ── Upload to Firebase Storage ──────────────────────
      final storagePath = 'recordings/$userId/$cameraId/$recId.mp4';
      final ref = _storage.ref(storagePath);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'cameraId':   cameraId,
            'cameraName': cameraName,
            'userId':     userId,
          },
        ),
      );

      final snapshot    = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[Recording] Uploaded → $downloadUrl');

      // ── Save metadata to Firestore ──────────────────────
      // Use FieldValue.serverTimestamp() — not Timestamp.now() (deprecated)
      final model = RecordingModel(
        id:              recId,
        cameraId:        cameraId,
        cameraName:      cameraName,
        userId:          userId,
        startedAt:       _startTime!,
        durationSeconds: duration,
        downloadUrl:     downloadUrl,
        storagePath:     storagePath,
        fileSizeBytes:   fileSize,
      );

      await _firestore
          .collection('recordings')
          .doc(recId)
          .set({
            ...model.toFirestore(),
            'startedAt': FieldValue.serverTimestamp(), // server-side timestamp
          });

      debugPrint('[Recording] Metadata saved to Firestore (doc: $recId)');

      // Clean up local temp file
      await file.delete();
      _localPath  = null;
      _startTime  = null;

      return model;
    } catch (e) {
      debugPrint('[Recording] Error: $e');
      _recorder  = null;
      _localPath = null;
      _startTime = null;
      return null;
    }
  }

  // ── Fetch recordings for a camera ────────────────────────
  Future<List<RecordingModel>> fetchRecordings({String? cameraId}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('recordings')
        .orderBy('startedAt', descending: true)
        .limit(50);

    if (cameraId != null) {
      query = query.where('cameraId', isEqualTo: cameraId);
    }

    final snap = await query.get();
    return snap.docs
        .map((d) => RecordingModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  // ── Delete a recording ────────────────────────────────────
  Future<void> deleteRecording(RecordingModel rec) async {
    // Delete from Storage
    try {
      await _storage.ref(rec.storagePath).delete();
    } catch (_) {}

    // Delete from Firestore
    await _firestore.collection('recordings').doc(rec.id).delete();
  }
}
