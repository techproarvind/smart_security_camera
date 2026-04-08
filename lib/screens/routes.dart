import 'package:get/get.dart';
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

// ignore_for_file: unused_import
class AppPages {
  static final routes = [
    GetPage(name: '/splash',         page: () => const SplashScreen()),
    GetPage(name: '/login',          page: () => const LoginScreen()),
    GetPage(name: '/role',           page: () => const RoleSelectScreen()),
    GetPage(name: '/dashboard',      page: () => const DashboardScreen()),
    GetPage(name: '/camera_detail',  page: () => const CameraDetailScreen()),
    GetPage(name: '/alerts',         page: () => const AlertsScreen()),
    GetPage(name: '/people_counter', page: () => const PeopleCounterScreen()),
    GetPage(name: '/settings',       page: () => const SettingsScreen()),
    GetPage(name: '/broadcast',      page: () => const CameraBroadcastScreen()),
    GetPage(name: '/live',           page: () => const LiveViewScreen()),
  ];
}

