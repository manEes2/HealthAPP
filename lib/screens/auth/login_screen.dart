import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_medium_app/common_widgets/custom_loader.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:medical_medium_app/core/utils/validators/validation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart' as my_auth;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<my_auth.AuthProvider>(context);

    return Scaffold(
      backgroundColor: medicalColors['primary'],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/images/bee.png', height: 80),
              const SizedBox(height: 16),
              Text(
                "Medical Medium App",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Besom',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Besom',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Please login to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Besom',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Email
              TextFormField(
                controller: emailCtrl,
                validator: (value) => Validators.validateEmail(value),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Colors.black, fontFamily: 'Besom'),
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: medicalColors['secondary']!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: passCtrl,
                validator: (value) =>
                    Validators.validateEmptyText('Password', value),
                obscureText: auth.isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Colors.black, fontFamily: 'Besom'),
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: Icon(
                      auth.isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: auth.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: medicalColors['secondary']!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: medicalColors['secondary'],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    final password = passCtrl.text;

                    CustomLoader.show(context, text: "Logging in...");
                    final error = await auth.login(email, password);
                    CustomLoader.hide(context);

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                      return;
                    }

                    // Fetch questionnaire status from Firestore
                    final user = FirebaseAuth.instance.currentUser;
                    bool questionnaireDone = false;

                    if (user != null) {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();

                      questionnaireDone =
                          userDoc.data()?['questionnaire_completed'] ?? false;

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(
                          'questionnaire_completed', questionnaireDone);
                    }

                    if (questionnaireDone) {
                      Navigator.pushReplacementNamed(context, '/welcome');
                    } else {
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: 'Besom',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Register Link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  "Don’t have an account? Register",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Besom',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
