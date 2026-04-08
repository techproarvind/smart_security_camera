import 'package:flutter/material.dart';
import 'package:smart_security_camera/model/camera_model.dart';

class CameraProvider extends ChangeNotifier {
  final List<CameraModel> _cameras = [
    CameraModel(id: '1', name: 'Front Door',    location: 'Home • Entrance',   status: CameraStatus.online,    peopleCount: 0),
    CameraModel(id: '2', name: 'Living Room',   location: 'Home • Indoor',      status: CameraStatus.recording, isRecording: true, peopleCount: 2),
    CameraModel(id: '3', name: 'Factory Floor', location: 'Factory • Zone A',   status: CameraStatus.online,    peopleCount: 14),
    CameraModel(id: '4', name: 'Warehouse Exit',location: 'Factory • Exit',     status: CameraStatus.offline,   motionEnabled: false),
    CameraModel(id: '5', name: 'Office Lobby',  location: 'Office • Reception', status: CameraStatus.online,    peopleCount: 5),
  ];

  List<CameraModel> get cameras => _cameras;
  int get onlineCount  => _cameras.where((c) => c.status != CameraStatus.offline).length;
  int get offlineCount => _cameras.where((c) => c.status == CameraStatus.offline).length;
  int get totalPeople  => _cameras.fold(0, (s, c) => s + c.peopleCount);

  CameraModel getById(String id) => _cameras.firstWhere((c) => c.id == id);

  void toggleMotion(String id) {
    final cam = getById(id);
    cam.motionEnabled = !cam.motionEnabled;
    notifyListeners();
  }

  void toggleCamera(String id) {
    final cam = getById(id);
    cam.status = cam.status == CameraStatus.offline
        ? CameraStatus.online
        : CameraStatus.offline;
    notifyListeners();
  }

  void updatePeopleCount(String id, int delta) {
    final cam = getById(id);
    cam.peopleCount = (cam.peopleCount + delta).clamp(0, 999);
    notifyListeners();
  }
}