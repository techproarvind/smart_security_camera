import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

enum UserRole { none, camera, viewer }

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _loggedIn = false.obs;
  final _userName = ''.obs;
  final _role     = UserRole.none.obs;

  bool     get loggedIn      => _loggedIn.value;
  String   get userName      => _userName.value;
  UserRole get role          => _role.value;
  bool     get isCameraDevice => _role.value == UserRole.camera;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  // ── Load persisted session on app start ───────────────────
  Future<void> _loadSession() async {
    final logged = await _storage.read(key: 'logged_in');
    if (logged == 'true') {
      _loggedIn.value = true;
      _userName.value = await _storage.read(key: 'user_name') ?? '';
      _role.value     = _roleFromString(await _storage.read(key: 'user_role') ?? '');
    }
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 4) {
      _loggedIn.value = true;
      _userName.value = email.split('@').first;
      await _storage.write(key: 'logged_in',  value: 'true');
      await _storage.write(key: 'user_name',  value: _userName.value);
      return true;
    }
    return false;
  }

  // ── Set role after role selection ─────────────────────────
  Future<void> setRole(UserRole role) async {
    _role.value = role;
    await _storage.write(key: 'user_role', value: role.name);
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _storage.deleteAll();
    _loggedIn.value = false;
    _userName.value = '';
    _role.value     = UserRole.none;
    Get.offAllNamed('/login');
  }

  UserRole _roleFromString(String s) {
    switch (s) {
      case 'camera': return UserRole.camera;
      case 'viewer': return UserRole.viewer;
      default:       return UserRole.none;
    }
  }
}
