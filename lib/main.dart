import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/controllers/notification_controller.dart';
import 'package:smart_security_camera/controllers/settings_controller.dart';
import 'package:smart_security_camera/firebase_options.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/routes.dart';
import 'package:smart_security_camera/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── Firebase ───────────────────────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler (must be top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(),          permanent: true);
    Get.put(CameraController(),        permanent: true);
    Get.put(AlertController(),         permanent: true);
    Get.put(NotificationController(),  permanent: true);
    Get.put(SettingsController(),      permanent: true);
  }
}
