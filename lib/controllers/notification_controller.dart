import 'package:get/get.dart';
import 'package:smart_security_camera/services/notification_service.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setup();
  }

  Future<void> _setup() async {
    await NotificationService.instance.initialize();
    fcmToken.value = NotificationService.instance.fcmToken ?? '';
  }
}
