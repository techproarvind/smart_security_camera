import 'package:flutter/material.dart';
import 'package:smart_security_camera/screens/alert_screen.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/camera_broad_cast.dart';
import 'package:smart_security_camera/screens/camera_details.dart';
import 'package:smart_security_camera/screens/dash_board.dart';
import 'package:smart_security_camera/screens/live_view.dart';
import 'package:smart_security_camera/screens/login_screen.dart';
import 'package:smart_security_camera/screens/people_count.dart';
import 'package:smart_security_camera/screens/role_select_screen.dart';
import 'package:smart_security_camera/screens/setting_screen.dart';
import 'package:smart_security_camera/screens/splash_screen.dart';

class SmartCamApp extends StatelessWidget {
  const SmartCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/camera_detail': (_) => const CameraDetailScreen(),
        '/alerts': (_) => const AlertsScreen(),
        '/people_counter': (_) => const PeopleCounterScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/role': (_) => const RoleSelectScreen(),
        '/broadcast': (_) => const CameraBroadcastScreen(),
        '/live': (_) => const LiveViewScreen(), // viewer phone
      },
    );
  }
}
