import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SmartCamApp());
}

class SmartCamApp extends StatelessWidget {
  const SmartCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartCam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialBinding: AppBinding(),
      initialRoute: '/splash',
      getPages: AppPages.routes,
    );
  }
}

/// Registers all controllers once at app start.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(),   permanent: true);
    Get.put(CameraController(), permanent: true);
    Get.put(AlertController(),  permanent: true);
  }
}
