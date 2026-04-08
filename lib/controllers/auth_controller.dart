import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

enum UserRole { none, camera, viewer }

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _auth    = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final _loggedIn = false.obs;
  final _userName = ''.obs;
  final _role     = UserRole.none.obs;

  bool     get loggedIn       => _loggedIn.value;
  String   get userName       => _userName.value;
  UserRole get role           => _role.value;
  bool     get isCameraDevice => _role.value == UserRole.camera;

  @override
  void onInit() {
    super.onInit();
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _loadRole();
  }

  // ── Firebase auth state listener ──────────────────────────
  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      _loggedIn.value = true;
      _userName.value = user.displayName ?? user.email?.split('@').first ?? '';
    } else {
      _loggedIn.value = false;
      _userName.value = '';
      _role.value     = UserRole.none;
    }
  }

  Future<void> _loadRole() async {
    final saved = await _storage.read(key: 'user_role');
    _role.value = _roleFromString(saved ?? '');
  }

  // ── Login ─────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Sign Up ───────────────────────────────────────────────
  Future<String?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Set display name from email
      await cred.user?.updateDisplayName(email.split('@').first);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Set role after role selection ─────────────────────────
  Future<void> setRole(UserRole role) async {
    _role.value = role;
    await _storage.write(key: 'user_role', value: role.name);
  }

  // ── Forgot Password ───────────────────────────────────────
  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (_) {
      return 'Could not send reset email.';
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    await _storage.delete(key: 'user_role');
    _role.value = UserRole.none;
    Get.offAllNamed('/login');
  }

  // ── Firebase error → readable message ────────────────────
  String _authError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password.';
      case 'invalid-email':        return 'Invalid email address.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'too-many-requests':    return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection.';
      case 'invalid-credential':   return 'Invalid email or password.';
      default:                     return 'Authentication failed ($code).';
    }
  }

  UserRole _roleFromString(String s) {
    switch (s) {
      case 'camera': return UserRole.camera;
      case 'viewer': return UserRole.viewer;
      default:       return UserRole.none;
    }
  }
}
