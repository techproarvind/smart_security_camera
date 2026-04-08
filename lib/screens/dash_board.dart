import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/camera_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  static const String _cameraId = 'cam_001';
  static const _titles = ['Cameras', 'Alerts', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth   = AuthController.to;
      final alertC = AlertController.to;

      return Scaffold(
        appBar: AppBar(
          title: Text(_titles[_tab]),
          leading: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Get.toNamed('/alerts'),
                ),
                if (alertC.unreadCount > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${alertC.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Get.toNamed('/settings'),
            ),
          ],
        ),

        body: IndexedStack(
          index: _tab,
          children: const [CamerasTab(), AlertsTab(), AnalyticsTab()],
        ),

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: auth.isCameraDevice ? AppTheme.primary : AppTheme.info,
          foregroundColor: AppTheme.bg,
          icon: Icon(auth.isCameraDevice ? Icons.videocam : Icons.personal_video),
          label: Text(
            auth.isCameraDevice ? 'Go Live' : 'Watch Live',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          onPressed: () {
            if (auth.isCameraDevice) {
              Get.toNamed('/broadcast', arguments: _cameraId);
            } else {
              Get.toNamed('/live', arguments: _cameraId);
            }
          },
        ),

        bottomNavigationBar: NavigationBar(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withOpacity(0.15),
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam, color: AppTheme.primary),
              label: 'Cameras',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: alertC.unreadCount > 0,
                label: Text('${alertC.unreadCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications, color: AppTheme.primary),
              label: 'Alerts',
            ),
            const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics, color: AppTheme.primary),
              label: 'Analytics',
            ),
          ],
        ),
      );
    });
  }
}
