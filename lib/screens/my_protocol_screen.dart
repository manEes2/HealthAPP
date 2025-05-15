import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProtocolScreen extends StatelessWidget {
  const MyProtocolScreen({super.key});

  Future<Map<String, dynamic>?> _getQuestionnaireData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('questionnaires')
        .doc(uid)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Healing Protocol")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getQuestionnaireData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text(
                    "No protocol found. Please complete the questionnaire."));
          }

          final data = snapshot.data!;
          final fatRatio = data['fatRatio'] ?? 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 👤 User Input Summary
              _buildSectionTitle("📝 Your Input Summary"),
              _buildInfoCard("Health History", data['healthHistory']),
              _buildInfoCard("Food History", data['foodHistory']),
              _buildInfoCard("Symptoms", data['bodySymptoms']),
              _buildInfoCard("Trouble Foods", data['troubleFoods']),
              _buildInfoCard("Fat Ratio", "${fatRatio.toStringAsFixed(1)}%"),

              const SizedBox(height: 30),

              // 🛠️ Personalized Protocol
              _buildSectionTitle("🛠 Personalized Healing Protocol"),
              _buildProtocolTip("Start with 10-day cleanse using lemon water"),
              _buildProtocolTip(
                  "Eat healing foods: papaya, wild blueberries, leafy greens"),

              if (fatRatio > 25)
                _buildProtocolTip(
                    "High fat ratio detected — Begin with liver detox + green juices"),

              if (data['bodySymptoms']
                  .toString()
                  .toLowerCase()
                  .contains("head"))
                _buildProtocolTip(
                    "Headaches? Increase hydration and magnesium-rich foods"),

              if (data['troubleFoods']
                  .toString()
                  .toLowerCase()
                  .contains("gluten"))
                _buildProtocolTip(
                    "Avoid gluten-based suggestions — use grain-free alternatives"),
            ],
          );
        },
      ),
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
