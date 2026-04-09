class RecordingModel {
  final String id;
  final String cameraId;
  final String cameraName;
  final String userId;
  final DateTime startedAt;
  final int durationSeconds;
  final String downloadUrl;
  final String storagePath;
  final int fileSizeBytes;

  const RecordingModel({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.userId,
    required this.startedAt,
    required this.durationSeconds,
    required this.downloadUrl,
    required this.storagePath,
    required this.fileSizeBytes,
  });

  // Duration as MM:SS string
  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // File size as human-readable string
  String get sizeLabel {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Firestore → model
  factory RecordingModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return RecordingModel(
      id:              docId,
      cameraId:        data['cameraId']       as String? ?? '',
      cameraName:      data['cameraName']     as String? ?? '',
      userId:          data['userId']         as String? ?? '',
      startedAt:       (data['startedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      durationSeconds: data['durationSeconds'] as int? ?? 0,
      downloadUrl:     data['downloadUrl']    as String? ?? '',
      storagePath:     data['storagePath']    as String? ?? '',
      fileSizeBytes:   data['fileSizeBytes']  as int? ?? 0,
    );
  }

  // Model → Firestore (using FieldValue.serverTimestamp() on write)
  Map<String, dynamic> toFirestore() => {
    'cameraId':        cameraId,
    'cameraName':      cameraName,
    'userId':          userId,
    'durationSeconds': durationSeconds,
    'downloadUrl':     downloadUrl,
    'storagePath':     storagePath,
    'fileSizeBytes':   fileSizeBytes,
  };
}
