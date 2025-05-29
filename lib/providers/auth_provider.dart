import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  String? get userName => _user?.email.split('@')[0];

  String? _realUserName;
  String? get realUserName => _realUserName;

  bool _isHomePageLinked = false;
  bool get isHomePageLinked => _isHomePageLinked;
  void toggleHomePageLink() {
    _isHomePageLinked = !_isHomePageLinked;
    notifyListeners();
  }

  bool _showAdvancedOptions = false;
  bool get showAdvancedOptions => _showAdvancedOptions;
  void toggleAdvancedOptions() {
    _showAdvancedOptions = !_showAdvancedOptions;
    notifyListeners();
  }

  // Login with email verification check
  Future<String?> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      if (result != null) {
        if (!result.emailVerified) {
          await _authService.logout(); // Force logout if not verified
          return 'Please verify your email before logging in.';
        }

        _user = UserModel(uid: result.uid, email: result.email!);
        await fetchRealUserName();

        // Save login status to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('questionnaire_completed', false);
        notifyListeners();
        return null; // success
      } else {
        return 'Login failed. Please try again or check email for verification.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during login.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Register and send email verification
  Future<String?> register(String email, String password) async {
    try {
      final result = await _authService.register(email, password);
      if (result != null) {
        _user = UserModel(uid: result.uid, email: result.email!);
        await fetchRealUserName();
        notifyListeners();
        return null;
      } else {
        return 'Registration failed. Try again.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during registration.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('questionnaire_completed');
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

  Future<void> fetchRealUserName() async {
    // Simulate fetching user's real name from database, using _user's uid.
    if (_user != null) {
      // Replace the below simulation with an actual database fetch in production.
      _realUserName = "RealName_${_user!.uid}";
      notifyListeners();
    }
  }
}
