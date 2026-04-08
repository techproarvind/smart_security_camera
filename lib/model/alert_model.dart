import 'package:flutter/material.dart';
import 'package:smart_security_camera/screens/app_theme.dart';

class AlertModel {
  final String id;
  final String cameraId;
  final String cameraName;
  final String type; // 'motion' | 'intrusion' | 'entry' | 'exit'
  final DateTime timestamp;
  bool isRead;

  AlertModel({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  String get typeLabel {
    switch (type) {
      case 'motion':    return 'Motion Detected';
      case 'intrusion': return 'Intrusion Alert';
      case 'entry':     return 'Person Entered';
      case 'exit':      return 'Person Exited';
      default:          return 'Alert';
    }
  }

  IconData get icon {
    switch (type) {
      case 'motion':    return Icons.directions_run;
      case 'intrusion': return Icons.warning_amber_rounded;
      case 'entry':     return Icons.login_rounded;
      case 'exit':      return Icons.logout_rounded;
      default:          return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'intrusion': return AppTheme.danger;
      case 'motion':    return AppTheme.warning;
      default:          return AppTheme.info;
    }
  }
}