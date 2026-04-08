import 'dart:async';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/model/alert_model.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/services/notification_service.dart';

class CameraController extends GetxController {
  static CameraController get to => Get.find();

  final _cameras = <CameraModel>[].obs;
  final _uuid    = const Uuid();
  final _motionTimers = <String, Timer>{};

  List<CameraModel> get cameras  => _cameras;
  int get onlineCount            => _cameras.where((c) => c.status != CameraStatus.offline).length;
  int get offlineCount           => _cameras.where((c) => c.status == CameraStatus.offline).length;
  int get totalPeople            => _cameras.fold(0, (s, c) => s + c.peopleCount);
  int get totalViolations        => _cameras.fold(0, (s, c) => s + c.safetyViolations);

  CameraModel? getById(String id) {
    try { return _cameras.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  void addCamera({required String name, required String location}) {
    _cameras.add(CameraModel(
      id:       _uuid.v4(),
      name:     name.trim(),
      location: location.trim().isEmpty ? 'Unknown Location' : location.trim(),
      status:   CameraStatus.online,
    ));
  }

  void removeCamera(String id) {
    _motionTimers[id]?.cancel();
    _motionTimers.remove(id);
    _cameras.removeWhere((c) => c.id == id);
  }

  void toggleMotion(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].motionEnabled = !_cameras[i].motionEnabled;
    _cameras.refresh();
  }

  void toggleCamera(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].status = _cameras[i].status == CameraStatus.offline
        ? CameraStatus.online
        : CameraStatus.offline;
    _cameras.refresh();
  }

  // ── In / Out occupancy ────────────────────────────────────
  void logEntry(String id, {bool isMember = false}) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].peopleIn++;
    if (isMember) {
      _cameras[i].memberCount++;
    } else {
      _cameras[i].visitorCount++;
    }
    _cameras.refresh();
  }

  void logExit(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    if (_cameras[i].peopleOut < _cameras[i].peopleIn) {
      _cameras[i].peopleOut++;
    }
    _cameras.refresh();
  }

  void resetOccupancy(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].peopleIn    = 0;
    _cameras[i].peopleOut   = 0;
    _cameras[i].memberCount = 0;
    _cameras[i].visitorCount = 0;
    _cameras.refresh();
  }

  // ── Safety kit ────────────────────────────────────────────
  void toggleSafetyZone(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].safetyZoneEnabled = !_cameras[i].safetyZoneEnabled;
    _cameras.refresh();
  }

  void updateSafetyRequirements(String id, {
    bool? helmet, bool? vest, bool? goggles,
  }) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    if (helmet  != null) _cameras[i].requireHelmet  = helmet;
    if (vest    != null) _cameras[i].requireVest    = vest;
    if (goggles != null) _cameras[i].requireGoggles = goggles;
    _cameras.refresh();
  }

  void logSafetyCompliant(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].safetyCompliant++;
    _cameras.refresh();
  }

  void logSafetyViolation(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].safetyViolations++;
    _cameras.refresh();

    final camera = _cameras[i];
    // Fire alert for safety violation
    AlertController.to.addAlert(AlertModel(
      id:         _uuid.v4(),
      cameraId:   camera.id,
      cameraName: camera.name,
      type:       'intrusion',
      timestamp:  DateTime.now(),
    ));
    NotificationService.instance.showMotionAlert(
      cameraName: camera.name,
      location:   'Safety kit violation at ${camera.location}',
    );
  }

  void resetSafetyStats(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].safetyCompliant  = 0;
    _cameras[i].safetyViolations = 0;
    _cameras.refresh();
  }

  // ── Motion ────────────────────────────────────────────────
  void setMotionSensitivity(String id, MotionSensitivity sensitivity) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].motionSensitivity = sensitivity;
    _cameras.refresh();
  }

  void triggerMotion(String id) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    final camera = _cameras[i];
    if (camera.status == CameraStatus.offline) return;
    if (!camera.motionEnabled) return;

    camera.status            = CameraStatus.motion;
    camera.lastMotionAt      = DateTime.now();
    camera.motionEventsToday += 1;
    _cameras.refresh();

    AlertController.to.addAlert(AlertModel(
      id:         _uuid.v4(),
      cameraId:   camera.id,
      cameraName: camera.name,
      type:       'motion',
      timestamp:  DateTime.now(),
    ));
    NotificationService.instance.showMotionAlert(
      cameraName: camera.name,
      location:   camera.location,
    );

    final delay = _clearDelay(camera.motionSensitivity);
    _motionTimers[id]?.cancel();
    _motionTimers[id] = Timer(delay, () {
      final j = _cameras.indexWhere((c) => c.id == id);
      if (j == -1) return;
      if (_cameras[j].status == CameraStatus.motion) {
        _cameras[j].status = CameraStatus.online;
        _cameras.refresh();
      }
    });
  }

  Duration _clearDelay(MotionSensitivity s) {
    switch (s) {
      case MotionSensitivity.low:    return const Duration(seconds: 5);
      case MotionSensitivity.medium: return const Duration(seconds: 10);
      case MotionSensitivity.high:   return const Duration(seconds: 20);
    }
  }

  @override
  void onClose() {
    for (final t in _motionTimers.values) { t.cancel(); }
    super.onClose();
  }
}
