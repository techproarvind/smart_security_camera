enum CameraStatus { online, offline, recording, motion }

enum MotionSensitivity { low, medium, high }

class CameraModel {
  final String id;
  String name;
  String location;
  CameraStatus status;
  bool motionEnabled;
  bool isRecording;
  int peopleCount;
  final String thumbnailAsset;

  // Motion sensing
  MotionSensitivity motionSensitivity;
  DateTime? lastMotionAt;
  int motionEventsToday;

  CameraModel({
    required this.id,
    required this.name,
    required this.location,
    this.status = CameraStatus.online,
    this.motionEnabled = true,
    this.isRecording = false,
    this.peopleCount = 0,
    this.thumbnailAsset = '',
    this.motionSensitivity = MotionSensitivity.medium,
    this.lastMotionAt,
    this.motionEventsToday = 0,
  });
}
