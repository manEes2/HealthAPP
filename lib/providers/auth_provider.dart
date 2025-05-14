import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result != null) {
      _user = UserModel(uid: result.uid, email: result.email!);

      //saving user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('questionnaire_completed', false);
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    final result = await _authService.register(email, password);
    if (result != null) {
      _user = UserModel(uid: result.uid, email: result.email!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    // Clear user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    // Clear user data from the provider
    _user = null;
    notifyListeners();
  }

  // Password visibility toggle
  bool _isPasswordObscured = true;

  bool get isPasswordObscured => _isPasswordObscured;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }
}
