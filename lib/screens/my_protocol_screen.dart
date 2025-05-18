import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:health_app/core/const/app_color.dart';

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
        body: Stack(children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
            ),
          ),

          // Content
          FutureBuilder<Map<String, dynamic>>(
            future: _getProtocolData(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!['protocol'] == null) {
                return const Center(
                  child: Text("Your protocol is being generated..."),
                );
              }

              final protocolContent =
                  snapshot.data!['protocol']?['content'] as String?;

              return _buildProtocolContent(protocolContent);
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildProtocolContent(String? protocolContent) {
    return SingleChildScrollView(
      // Wrap with scroll view
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "🛠 Your Personalized Protocol",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Besom'),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          // Add height constraint
          constraints: const BoxConstraints(
              minHeight: 200, maxHeight: 1000 // Adjust based on your needs
              ),
          child: SingleChildScrollView(
            // Make markdown scrollable
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(
                    color: Colors.green[800],
                    fontSize: 22,
                    fontFamily: 'Besom'),
                h2: TextStyle(color: Colors.green[700], fontSize: 18),
                p: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultProtocolTips() {
    return const Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ProtocolTip("Start with morning lemon water"),
            ProtocolTip("Include leafy greens in every meal"),
            ProtocolTip("Practice deep breathing exercises"),
            ProtocolTip("Get 7-8 hours of sleep nightly"),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 16, fontFamily: 'Besom'),
            ),
          ),
        ],
      ),
    );
  }
}
