import 'package:flutter/material.dart';
import 'package:medical_medium_app/common_widgets/dotted_trail_painter.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trailPoints = [
      Offset(40, 100), // My Profile
      Offset(160, 130), // My Protocol
      Offset(300, 160), // My Goals
      Offset(270, 270), // My Progress
      Offset(240, 440), // MM School
      Offset(60, 500), // My Community
      Offset(140, 600), // Settings
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),

            // Dotted path
            Positioned.fill(
              child: CustomPaint(
                painter: DottedTrailPainter(trailPoints),
              ),
            ),

            // Content
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  children: [
                    _buildItem(context,
                        top: 64,
                        left: 20,
                        label: "My Profile",
                        icon: "profile.png", onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    }),
                    _buildItem(context,
                        top: 90,
                        left: 130,
                        label: "My Protocol",
                        icon: "protocol.png", onTap: () {
                      Navigator.pushNamed(context, '/protocol');
                    }),
                    _buildItem(context,
                        top: 132,
                        right: 48,
                        label: "My Goals",
                        icon: "goals.png", onTap: () {
                      Navigator.pushNamed(context, '/goals');
                    }),
                    _buildItem(context,
                        top: 240,
                        right: 80,
                        label: "My Progress",
                        icon: "progress.png", onTap: () {
                      Navigator.pushNamed(context, '/home');
                    }),
                    _buildItem(context,
                        bottom: 200,
                        left: 40,
                        label: "My Community",
                        icon: "community.png", onTap: () {
                      Navigator.pushNamed(context, '/shop');
                    }),
                    _buildItem(context,
                        bottom: 100,
                        left: 128,
                        label: "Settings",
                        icon: "settings.png", onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    }),
                    _buildItem(context,
                        top: 380,
                        right: 124,
                        label: "MM School",
                        icon: "school.png", onTap: () {
                      Navigator.pushNamed(context, '/school');
                    }),
                  ],
                ),
              ),
            ),

            // Welcome text
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Besom',
                    color: Colors.brown.shade800,
                    shadows: [
                      Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                          offset: Offset(1, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context,
      {double? top,
      double? bottom,
      double? left,
      double? right,
      required String label,
      required String icon,
      required VoidCallback onTap}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/$icon',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.brown.shade800,
                fontFamily: 'Besom',
                shadows: [
                  Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                      offset: Offset(1, 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
