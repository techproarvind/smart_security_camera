import 'package:flutter/material.dart';
import 'package:smart_security_camera/model/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  final List<AlertModel> _alerts = [];

  List<AlertModel> get alerts => List.unmodifiable(_alerts);
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  void addAlert(AlertModel alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  void markRead(String id) {
    final a = _alerts.firstWhere((a) => a.id == id, orElse: () => throw Exception());
    a.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final a in _alerts) { a.isRead = true; }
    notifyListeners();
  }

  void clearAll() {
    _alerts.clear();
    notifyListeners();
  }
}
