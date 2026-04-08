import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_security_camera/model/camera_model.dart';

class CameraProvider extends ChangeNotifier {
  final List<CameraModel> _cameras = [];
  final _uuid = const Uuid();

  List<CameraModel> get cameras => List.unmodifiable(_cameras);

  int get onlineCount  => _cameras.where((c) => c.status != CameraStatus.offline).length;
  int get offlineCount => _cameras.where((c) => c.status == CameraStatus.offline).length;
  int get totalPeople  => _cameras.fold(0, (s, c) => s + c.peopleCount);

  CameraModel? getById(String id) {
    try { return _cameras.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  void addCamera({ required String name, required String location }) {
    _cameras.add(CameraModel(
      id:       _uuid.v4(),
      name:     name.trim(),
      location: location.trim().isEmpty ? 'Unknown Location' : location.trim(),
      status:   CameraStatus.online,
    ));
    notifyListeners();
  }

  void removeCamera(String id) {
    _cameras.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void toggleMotion(String id) {
    final cam = getById(id);
    if (cam == null) return;
    cam.motionEnabled = !cam.motionEnabled;
    notifyListeners();
  }

  void toggleCamera(String id) {
    final cam = getById(id);
    if (cam == null) return;
    cam.status = cam.status == CameraStatus.offline
        ? CameraStatus.online
        : CameraStatus.offline;
    notifyListeners();
  }

  void updatePeopleCount(String id, int delta) {
    final cam = getById(id);
    if (cam == null) return;
    cam.peopleCount = (cam.peopleCount + delta).clamp(0, 999);
    notifyListeners();
  }
}
