import 'package:flutter/material.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:medical_medium_app/core/utils/validators/validation.dart';
import 'package:provider/provider.dart';
import 'package:medical_medium_app/providers/temp_auth_provider.dart';

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
    final auth = Provider.of<TempAuthProvider>(context);

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
              const Text(
                "Medical Medium App",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Besom',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              const Align(
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
              const Align(
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
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Besom',
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                validator: (value) => Validators.validateEmptyText('Password', value),
                obscureText: auth.isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Besom',
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.green),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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

                    final error = await auth.login(email, password);
                    if (error != null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      }
                      return;
                    }

                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/welcome');
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
                child: const Text(
                  "Don't have an account? Register",
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
