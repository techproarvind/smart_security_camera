import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/provider/alert_provider.dart';
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
            onPressed: context.read<AlertProvider>().markAllRead,
            child: const Text('Clear all', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: const AlertsTab(),
    );
  }
}