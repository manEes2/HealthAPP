import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyProtocolScreen extends StatelessWidget {
  const MyProtocolScreen({super.key});

  Future<Map<String, dynamic>> _getCombinedData(String uid) async {
    final questionnaire = await FirebaseFirestore.instance
        .collection('questionnaires')
        .doc(uid)
        .get();

    final protocol =
        await FirebaseFirestore.instance.collection('protocols').doc(uid).get();

    return {
      'questionnaire': questionnaire.data(),
      'protocol': protocol.data(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("My Healing Protocol")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCombinedData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['questionnaire'] == null) {
            return const Center(
              child: Text("Complete the questionnaire first"),
            );
          }

          final data = snapshot.data!;
          final protocolContent = data['protocol']?['content'] as String?;
          final questionnaireData =
              data['questionnaire'] as Map<String, dynamic>;

          return _buildProtocolContent(
            context,
            protocolContent: protocolContent,
            questionnaireData: questionnaireData,
          );
        },
      ),
    );
  }

  Widget _buildProtocolContent(
    BuildContext context, {
    required Map<String, dynamic> questionnaireData,
    String? protocolContent,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle("📝 Your Health Profile"),
        _buildUserInfoCards(questionnaireData),
        const SizedBox(height: 30),
        _buildSectionTitle("🛠 Personalized Protocol"),
        if (protocolContent != null)
          _buildAIProtocol(protocolContent)
        else
          _buildFallbackProtocol(questionnaireData),
      ],
    );
  }

  Widget _buildAIProtocol(String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(color: Colors.green[800], fontSize: 24),
            h2: TextStyle(color: Colors.green[700], fontSize: 20),
            p: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackProtocol(Map<String, dynamic> data) {
    final fatRatio = data['fatRatio'] ?? 0.0;
    final troubleFoods = List<String>.from(data['troubleFoods'] ?? []);
    final symptoms = Map<String, dynamic>.from(data['symptomDetails'] ?? {});

    return Column(
      children: [
        _buildProtocolTip("Start with 10-day cleanse using lemon water"),
        _buildProtocolTip(
            "Eat healing foods: papaya, blueberries, leafy greens"),
        if (fatRatio > 25)
          _buildProtocolTip("High fat ratio detected - Begin liver detox"),
        if (symptoms.keys.any((part) => part.toLowerCase().contains("head")))
          _buildProtocolTip("For headaches: Increase hydration & magnesium"),
        if (troubleFoods.contains("Gluten"))
          _buildProtocolTip("Use gluten-free alternatives in recipes"),
      ],
    );
  }

  Widget _buildUserInfoCards(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildInfoCard(
            "Health History", (data['healthHistory'] as List).join(", ")),
        _buildInfoCard(
            "Trouble Foods", (data['troubleFoods'] as List).join(", ")),
        _buildInfoCard(
            "Fat Ratio", "${(data['fatRatio'] ?? 0.0).toStringAsFixed(1)}%"),
        _buildInfoCard(
          "Symptoms",
          (data['symptomDetails'] as Map)
              .entries
              .map((e) => "${e.key} (${e.value}/10)")
              .join(", "),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      color: Colors.green[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: Colors.green),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildProtocolTip(String tip) {
    return Card(
      color: Colors.lightGreen[100],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
