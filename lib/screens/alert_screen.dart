import 'package:flutter/material.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/camera_tab.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          TextButton(
            onPressed: AlertController.to.clearAll,
            child: const Text('Clear all', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: const AlertsTab(),
    );
  }
}
