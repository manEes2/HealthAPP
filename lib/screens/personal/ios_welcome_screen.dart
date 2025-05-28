import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:medical_medium_app/common_widgets/dotted_trail_painter.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trailPoints = [
      Offset(40, 100),  // My Profile
      Offset(160, 130), // My Protocol
      Offset(300, 160), // My Goals
      Offset(270, 270), // My Progress
      Offset(240, 440), // MM School
      Offset(60, 500),  // My Community
      Offset(140, 600), // Settings
    ];

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: Stack(
        children: [
          // Background image with iOS-style blur overlay
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: CupertinoColors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dotted path with iOS-style refinements
          Positioned.fill(
          child: CustomPaint(
            painter: DottedTrailPainter(
              trailPoints,
            ),
          ),
          ),

          // Content
          SafeArea(
            child: Stack(
              children: [
                _buildItem(
                  context,
                  top: 64,
                  left: 20,
                  label: "My Profile",
                  icon: "profile.png",
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildItem(
                  context,
                  top: 90,
                  left: 130,
                  label: "My Protocol",
                  icon: "protocol.png",
                  onTap: () => Navigator.pushNamed(context, '/protocol'),
                ),
                _buildItem(
                  context,
                  top: 132,
                  right: 64,
                  label: "My Goals",
                  icon: "goals.png",
                  onTap: () => Navigator.pushNamed(context, '/goals'),
                ),
                _buildItem(
                  context,
                  top: 240,
                  right: 80,
                  label: "My Progress",
                  icon: "progress.png",
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),
                _buildItem(
                  context,
                  bottom: 300,
                  left: 40,
                  label: "My Community",
                  icon: "community.png",
                  onTap: () => Navigator.pushNamed(context, '/shop'),
                ),
                _buildItem(
                  context,
                  bottom: 180,
                  left: 128,
                  label: "Settings",
                  icon: "settings.png",
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                _buildItem(
                  context,
                  top: 380,
                  right: 124,
                  label: "MM School",
                  icon: "school.png",
                  onTap: () => Navigator.pushNamed(context, '/school'),
                ),
              ],
            ),
          ),

          // Welcome text with iOS styling
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Besom',
                    color: CupertinoColors.systemBrown,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/$icon',
                width: 50,
                height: 50,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Besom',
                  color: CupertinoColors.systemBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
