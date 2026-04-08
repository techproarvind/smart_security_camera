enum CameraStatus { online, offline, recording }

class CameraModel {
  final String id;
  final String name;
  final String location;
  CameraStatus status;
  bool motionEnabled;
  bool isRecording;
  int peopleCount;
  final String thumbnailAsset; // use placeholder in real app

  CameraModel({
    required this.id,
    required this.name,
    required this.location,
    this.status = CameraStatus.online,
    this.motionEnabled = true,
    this.isRecording = false,
    this.peopleCount = 0,
    this.thumbnailAsset = '',
  });
}