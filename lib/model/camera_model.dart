enum CameraStatus { online, offline, recording, motion }

enum MotionSensitivity { low, medium, high }

class CameraModel {
  final String id;
  String name;
  String location;
  CameraStatus status;
  bool motionEnabled;
  bool isRecording;
  final String thumbnailAsset;

  // Motion sensing
  MotionSensitivity motionSensitivity;
  DateTime? lastMotionAt;
  int motionEventsToday;

  // Occupancy — in / out tracking
  int peopleIn;       // total who entered today
  int peopleOut;      // total who exited today
  int memberCount;    // known members detected today
  int visitorCount;   // unknown visitors detected today

  // Safety kit compliance
  bool safetyZoneEnabled;     // is this a safety-mandatory area?
  bool requireHelmet;
  bool requireVest;
  bool requireGoggles;
  int safetyCompliant;        // people correctly equipped
  int safetyViolations;       // people missing required kit

  CameraModel({
    required this.id,
    required this.name,
    required this.location,
    this.status = CameraStatus.online,
    this.motionEnabled = true,
    this.isRecording = false,
    this.thumbnailAsset = '',
    this.motionSensitivity = MotionSensitivity.medium,
    this.lastMotionAt,
    this.motionEventsToday = 0,
    this.peopleIn = 0,
    this.peopleOut = 0,
    this.memberCount = 0,
    this.visitorCount = 0,
    this.safetyZoneEnabled = false,
    this.requireHelmet = true,
    this.requireVest = true,
    this.requireGoggles = false,
    this.safetyCompliant = 0,
    this.safetyViolations = 0,
  });

  // Current occupancy = entered minus exited
  int get peopleCount => (peopleIn - peopleOut).clamp(0, 9999);

  // Compliance rate 0–100
  int get safetyComplianceRate {
    final total = safetyCompliant + safetyViolations;
    if (total == 0) return 100;
    return ((safetyCompliant / total) * 100).round();
  }
}
