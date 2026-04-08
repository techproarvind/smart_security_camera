import 'package:flutter/material.dart';

enum UserRole { none, camera, viewer }

class AuthProvider extends ChangeNotifier {
  bool _loggedIn = false;
  String _userName = '';
  UserRole _role = UserRole.none;

  bool get loggedIn => _loggedIn;
  String get userName => _userName;
  UserRole get role => _role;
  bool get isCameraDevice => _role == UserRole.camera;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 4) {
      _loggedIn = true;
      _userName = email.split('@').first;
      notifyListeners();
      return true;
    }
    return false;
  }

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _role = UserRole.none;
    notifyListeners();
  }
}