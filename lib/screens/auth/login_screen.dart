import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/custom_loader.dart';
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

  void Dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<my_auth.AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Text("Login",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Email field
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )),
              ),
              SizedBox(height: 20),

              // Password field
              TextField(
                controller: passCtrl,
                obscureText: auth.isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      auth.isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => auth.togglePasswordVisibility(),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields")),
                      );
                      return;
                    }

                    CustomLoader.show(context, text: "Logging in...");
                    await auth.login(emailCtrl.text, passCtrl.text);
                    CustomLoader.hide(context);

                    if (auth.user != null) {
                      final user = FirebaseAuth.instance.currentUser;
                      bool questionnaireDone = false;

                      if (user != null) {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        questionnaireDone =
                            userDoc.data()?['questionnaire_completed'] ?? false;

                        // Optionally update local cache
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool(
                            'questionnaire_completed', questionnaireDone);
                      }

                      if (questionnaireDone) {
                        Navigator.pushNamed(context, '/home');
                      } else {
                        Navigator.pushNamed(context, '/onboarding');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login failed")),
                      );
                    }
                  },
                  child: Text("Login",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              SizedBox(height: 20),

              //register button
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  "Don’t have an account? Register",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
