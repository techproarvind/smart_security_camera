import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/provider/alert_provider.dart';
import 'package:smart_security_camera/provider/auth_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/camera_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final alertP = context.watch<AlertProvider>();
    final authP  = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCam'),
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            child: Text(
              authP.userName.isNotEmpty ? authP.userName[0].toUpperCase() : 'U',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.pushNamed(context, '/alerts')),
              if (alertP.unreadCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${alertP.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [CamerasTab(), AlertsTab(), AnalyticsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.videocam_outlined),
            selectedIcon: const Icon(Icons.videocam, color: AppTheme.primary),
            label: 'Cameras',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: alertP.unreadCount > 0,
              label: Text('${alertP.unreadCount}'),
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
  }
}