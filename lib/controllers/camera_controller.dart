import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_security_camera/model/camera_model.dart';

class CameraController extends GetxController {
  static CameraController get to => Get.find();

  final _cameras = <CameraModel>[].obs;
  final _uuid    = const Uuid();

  List<CameraModel> get cameras    => _cameras;
  int get onlineCount              => _cameras.where((c) => c.status != CameraStatus.offline).length;
  int get offlineCount             => _cameras.where((c) => c.status == CameraStatus.offline).length;
  int get totalPeople              => _cameras.fold(0, (s, c) => s + c.peopleCount);

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

  void removeCamera(String id) => _cameras.removeWhere((c) => c.id == id);

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

  void updatePeopleCount(String id, int delta) {
    final i = _cameras.indexWhere((c) => c.id == id);
    if (i == -1) return;
    _cameras[i].peopleCount = (_cameras[i].peopleCount + delta).clamp(0, 999);
    _cameras.refresh();
  }
}
