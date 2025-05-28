import 'package:flutter/material.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class MMSchoolScreen extends StatelessWidget {
  const MMSchoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            // Background texture
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "📚 MM School",
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Besom',
                      color: Colors.brown.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Explore natural ways to heal and learn about your body, emotions, and nutrition.",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontFamily: 'Besom'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Illustration
                  Image.asset(
                    'assets/images/mm_school_tree.png',
                    height: 180,
                  ),
                  const SizedBox(height: 20),

                  // Info Cards
                  Expanded(
                    child: ListView(
                      children: const [
                        _SchoolCard(
                          title: "🧠 Learn About Your Body",
                          description:
                              "Understand body systems, symptoms, and functions holistically.",
                        ),
                        _SchoolCard(
                          title: "🌱 Root Causes",
                          description:
                              "Discover emotional and nutritional causes behind symptoms.",
                        ),
                        _SchoolCard(
                          title: "🍏 Natural Healing",
                          description:
                              "Explore foods, herbs, and lifestyle changes for healing.",
                        ),
                        _SchoolCard(
                          title: "💚 Emotional Wellness",
                          description:
                              "Learn how emotions affect your body and how to process them.",
                        ),
                        _SchoolCard(
                          title: "🥦 Nutrition Basics",
                          description:
                              "Study trouble foods, healing foods, and daily meal tips.",
                        ),
                      ],
                    ),
                  ),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to course list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Course list coming soon!"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Start Learning",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Besom',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final String title;
  final String description;

  const _SchoolCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.yellow.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Besom'),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                  fontSize: 18, color: Colors.black87, fontFamily: 'Besom'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
