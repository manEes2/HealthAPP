import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
    final userId = Provider.of<AuthProvider>(context).user?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Healing Protocol")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getQuestionnaireData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text(
                    "No protocol found. Please complete the questionnaire."));
          }

          final data = snapshot.data!;
          final fatRatio = data['fatRatio'] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text("Health History: ${data['healthHistory']}",
                    style: TextStyle(fontSize: 16)),
                Text("Food History: ${data['foodHistory']}",
                    style: TextStyle(fontSize: 16)),
                Text("Symptoms: ${data['bodySymptoms']}",
                    style: TextStyle(fontSize: 16)),
                Text("Trouble Foods: ${data['troubleFoods']}",
                    style: TextStyle(fontSize: 16)),
                Text("Fat Ratio: ${fatRatio.toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Divider(),
                Text("🛠 Your Personalized Protocol",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 8),
                if (fatRatio > 25)
                  Text("- Start with liver detox + green juices",
                      style: TextStyle(color: Colors.green[800])),
                if (data['bodySymptoms']
                    .toString()
                    .toLowerCase()
                    .contains("head"))
                  Text("- Headaches suggest hydration + magnesium-rich foods",
                      style: TextStyle(color: Colors.green[800])),
                if (data['troubleFoods']
                    .toString()
                    .toLowerCase()
                    .contains("gluten"))
                  Text(
                      "- Avoid gluten-based protocols & use grain-free alternatives"),
                SizedBox(height: 20),
                Text("- Begin with 10-day cleanse + lemon water",
                    style: TextStyle(color: Colors.green[800])),
                Text(
                    "- Eat healing foods: papaya, wild blueberries, leafy greens",
                    style: TextStyle(color: Colors.green[800])),
              ],
            ),
          );
        },
      ),
    );
  }
}
