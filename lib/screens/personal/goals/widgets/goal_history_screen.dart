import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:intl/intl.dart';

class GoalHistoryScreen extends StatelessWidget {
  const GoalHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('date', descending: true)
        .get();

    return snapshots.docs
        .map((doc) => {
              'date': doc.id,
              'completedGoals': List<String>.from(doc['completedGoals'] ?? [])
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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

            // Header
            Positioned(
              top: 40,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 16),
                child: Text(
                  "Goal History",
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Besom',
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),
            ),

            // Content
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = snapshot.data ?? [];

                if (history.isEmpty) {
                  return const Center(
                      child: Text(
                    "No history found.",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Besom',
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        shadows: [
                          Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                              offset: Offset(1, 1)),
                        ]),
                  ));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 130, left: 16, right: 16),
                  itemCount: history.length,
                  itemBuilder: (_, index) {
                    final entry = history[index];
                    final date = DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(entry['date']));
                    final goals = entry['completedGoals'] as List<String>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.yellow.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📅 $date",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Besom',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ...goals.map((g) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text(g,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Besom',
                                          )),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
