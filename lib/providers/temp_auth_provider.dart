import 'package:flutter/material.dart';

class TempAuthProvider with ChangeNotifier {
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  // Temporary login function that just navigates to welcome screen
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please fill in all fields";
    }
    return null; // Return null means no error
  }
}
