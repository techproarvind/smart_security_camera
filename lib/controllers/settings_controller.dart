import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final pushNotifications = true.obs;
  final motionAlerts      = true.obs;
  final occupancyAlerts   = false.obs;
  final safetyAlerts      = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    pushNotifications.value = await _readBool('pref_push',     def: true);
    motionAlerts.value      = await _readBool('pref_motion',   def: true);
    occupancyAlerts.value   = await _readBool('pref_occupancy',def: false);
    safetyAlerts.value      = await _readBool('pref_safety',   def: true);
  }

  Future<bool> _readBool(String key, {required bool def}) async {
    final v = await _storage.read(key: key);
    if (v == null) return def;
    return v == 'true';
  }

  Future<void> togglePush() async {
    pushNotifications.value = !pushNotifications.value;
    await _storage.write(key: 'pref_push', value: '${pushNotifications.value}');
  }

  Future<void> toggleMotion() async {
    motionAlerts.value = !motionAlerts.value;
    await _storage.write(key: 'pref_motion', value: '${motionAlerts.value}');
  }

  Future<void> toggleOccupancy() async {
    occupancyAlerts.value = !occupancyAlerts.value;
    await _storage.write(key: 'pref_occupancy', value: '${occupancyAlerts.value}');
  }

  Future<void> toggleSafety() async {
    safetyAlerts.value = !safetyAlerts.value;
    await _storage.write(key: 'pref_safety', value: '${safetyAlerts.value}');
  }
}
