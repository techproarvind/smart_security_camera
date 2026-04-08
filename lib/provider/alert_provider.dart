import 'package:flutter/material.dart';
import 'package:smart_security_camera/model/alert_model.dart';

class AlertProvider extends ChangeNotifier {
  final List<AlertModel> _alerts = [
    AlertModel(id: 'a1', cameraId: '1', cameraName: 'Front Door',    type: 'intrusion', timestamp: DateTime.now().subtract(const Duration(minutes: 3)),  isRead: false),
    AlertModel(id: 'a2', cameraId: '2', cameraName: 'Living Room',   type: 'motion',    timestamp: DateTime.now().subtract(const Duration(minutes: 12)), isRead: false),
    AlertModel(id: 'a3', cameraId: '3', cameraName: 'Factory Floor', type: 'entry',     timestamp: DateTime.now().subtract(const Duration(minutes: 25)), isRead: true),
    AlertModel(id: 'a4', cameraId: '5', cameraName: 'Office Lobby',  type: 'exit',      timestamp: DateTime.now().subtract(const Duration(hours: 1)),    isRead: true),
    AlertModel(id: 'a5', cameraId: '1', cameraName: 'Front Door',    type: 'motion',    timestamp: DateTime.now().subtract(const Duration(hours: 2)),    isRead: true),
  ];

  List<AlertModel> get alerts => _alerts;
  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  void markRead(String id) {
    _alerts.firstWhere((a) => a.id == id).isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final a in _alerts) { a.isRead = true; }
    notifyListeners();
  }
}