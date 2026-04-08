import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _loggedIn = false;
  String _userName = '';
  bool get loggedIn => _loggedIn;
  String get userName => _userName;

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

  void logout() { _loggedIn = false; notifyListeners(); }
}