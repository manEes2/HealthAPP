import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:medical_medium_app/core/const/app_color.dart';

class MyProtocolScreen extends StatelessWidget {
  const MyProtocolScreen({super.key});

  Future<Map<String, dynamic>> _getProtocolData(String uid) async {
    final protocol =
        await FirebaseFirestore.instance.collection('protocols').doc(uid).get();

    return {
      'protocol': protocol.data(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),

            // Content
            FutureBuilder<Map<String, dynamic>>(
              future: _getProtocolData(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (!snapshot.hasData || snapshot.data!['protocol'] == null) {
                  return const Center(
                    child: Text(
                      "Your protocol is being generated...",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Besom',
                        color: Colors.black87,
                      ),
                    ),
                  );
                }

                final protocolContent =
                    snapshot.data!['protocol']?['content'] as String?;

                return _buildProtocolContent(protocolContent);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolContent(String? protocolContent) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "🌱 Your Healing Protocol",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Besom',
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            if (protocolContent != null)
              _buildAIProtocol(protocolContent)
            else
              _buildDefaultProtocolTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIProtocol(String content) {
    return Card(
      elevation: 6,
      color: Colors.yellow.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 1000),
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  fontFamily: 'Besom',
                ),
                h2: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C),
                ),
                p: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                listBullet: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Besom',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultProtocolTips() {
    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ProtocolTip("Start your day with warm lemon water 🍋"),
            ProtocolTip("Add leafy greens to every meal 🥬"),
            ProtocolTip("Do deep breathing for 5–10 mins daily 🌬️"),
            ProtocolTip("Get 7–8 hours of peaceful sleep 💤"),
          ],
        ),
      ),
    );
  }
}

class ProtocolTip extends StatelessWidget {
  final String tip;

  const ProtocolTip(this.tip, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa, color: Color(0xFF43A047), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Besom',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
