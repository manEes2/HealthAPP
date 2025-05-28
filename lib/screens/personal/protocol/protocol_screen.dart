import 'package:flutter/material.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:medical_medium_app/screens/personal/protocol/widget/my_protocol_screen.dart';

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({super.key});

  Widget _protocolCard({
    required String title,
    required String description,
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(iconPath, height: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Besom',
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Besom',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Besom',
          color: Colors.brown.shade800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: medicalColors['primary'],
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Text(
                    "🌿 Healing Protocols",
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'Besom',
                      color: Colors.brown.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionHeader("Healing Protocols"),
                _protocolCard(
                  title: "Liver Detox",
                  description:
                      "Morning lemon water, celery juice, avoid fats after 12 PM.",
                  iconPath: 'assets/icons/healing.png',
                ),
                _protocolCard(
                  title: "Gut Repair",
                  description:
                      "Papaya smoothies, aloe vera, zinc & B12 rich foods.",
                  iconPath: 'assets/icons/healing.png',
                ),
                _sectionHeader("Meditation Practices"),
                _protocolCard(
                  title: "Morning Grounding",
                  description:
                      "Sit quietly outdoors barefoot for 10 minutes daily.",
                  iconPath: 'assets/icons/meditation.png',
                ),
                _protocolCard(
                  title: "Sleep Calm",
                  description: "Breathing + guided visualization before bed.",
                  iconPath: 'assets/icons/meditation.png',
                ),
                _sectionHeader("Juice Recipes"),
                _protocolCard(
                  title: "Heavy Metal Detox Smoothie",
                  description:
                      "Banana, wild blueberries, spirulina, barley grass, cilantro.",
                  iconPath: 'assets/icons/juice.png',
                ),
                _protocolCard(
                  title: "Celery Juice",
                  description:
                      "Pure celery, drink on empty stomach every morning.",
                  iconPath: 'assets/icons/juice.png',
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.brown.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyProtocolScreen()),
                      );
                    },
                    icon: Image.asset('assets/icons/ai.png', height: 28),
                    label: const Text(
                      "AI Generated Protocol",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Besom',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
