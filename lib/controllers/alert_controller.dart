import 'package:get/get.dart';
import 'package:smart_security_camera/model/alert_model.dart';

class AlertController extends GetxController {
  static AlertController get to => Get.find();

  final _alerts = <AlertModel>[].obs;

  List<AlertModel> get alerts  => _alerts;
  int get unreadCount          => _alerts.where((a) => !a.isRead).length;

  void addAlert(AlertModel alert) => _alerts.insert(0, alert);

  void markRead(String id) {
    final i = _alerts.indexWhere((a) => a.id == id);
    if (i == -1) return;
    _alerts[i].isRead = true;
    _alerts.refresh();
  }

  void markAllRead() {
    for (final a in _alerts) { a.isRead = true; }
    _alerts.refresh();
  }

  void clearAll() => _alerts.clear();
}
