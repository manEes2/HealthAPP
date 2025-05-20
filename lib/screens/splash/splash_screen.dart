import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medical_medium_app/common_widgets/beehive_connecter_painter.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 5));
    final prefs = await SharedPreferences.getInstance();

    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    prefs.setBool('is_logged_in', isLoggedIn);

    if (!mounted) return;

    if (isLoggedIn) {
      final uid = user.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final isQuestionnaireCompleted =
          userDoc.data()?['questionnaire_completed'] ?? false;

      prefs.setBool('questionnaire_completed', isQuestionnaireCompleted);

      if (isQuestionnaireCompleted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: medicalColors['primary'],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            //map image
            Positioned(
              top: 60,
              child: Image.asset('assets/images/map.png', width: 120),
            ),

            //text
            Positioned(
              top: 180,
              child: Text(
                'Medical Medium App',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Besom',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //hive image
            Positioned(
              top: 320,
              right: 60,
              child: Image.asset('assets/images/hive.png', width: 100),
            ),

            // Connector line (CustomPaint)
            Positioned.fill(
              child: CustomPaint(
                painter: BeeHiveConnectorPainter(),
              ),
            ),

            // Bee image
            Positioned(
              left: 60,
              top: 400,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset('assets/images/bee.png', width: 50),
              ),
            ),

            //leaves and signpost images
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset('assets/images/leaves.png', width: 100),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset('assets/images/signpost.png', width: 120),
            ),
          ],
        ),
      ),
    );
  }
}
