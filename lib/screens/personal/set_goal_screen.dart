import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/core/const/app_color.dart';

class SetGoalsScreen extends StatefulWidget {
  const SetGoalsScreen({super.key});

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  TimeOfDay? _selectedTime;

  List<String> goals = [];
  List<Map<String, String>> reminders = [];

  bool isLoading = true;
  bool hasUserGoals = false;
  List<String> userGoals = [];
  List<String> predefinedGoals = [
    "Drink 8 glasses of water",
    "Walk 10,000 steps",
    "Meditate 10 minutes",
    "Eat 3 servings of vegetables",
    "Sleep 8 hours"
  ];

  @override
  void initState() {
    super.initState();
    fetchUserGoals();
  }

  Future<void> fetchUserGoals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      final fetchedGoals = List<String>.from(data?['goals'] ?? []);
      setState(() {
        userGoals = fetchedGoals;
        hasUserGoals = fetchedGoals.isNotEmpty;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    List<String> existingGoals = [];
    List<Map<String, String>> existingReminders = [];

    if (snapshot.exists) {
      final data = snapshot.data();
      existingGoals = List<String>.from(data?['goals'] ?? []);
      existingReminders =
          List<Map<String, String>>.from(data?['reminders'] ?? []);
    }

    for (final g in goals) {
      if (!existingGoals.contains(g)) {
        existingGoals.add(g);
      }
    }

    for (final r in reminders) {
      bool alreadyExists = existingReminders.any(
        (e) => e['title'] == r['title'] && e['time'] == r['time'],
      );
      if (!alreadyExists) {
        existingReminders.add(r);
      }
    }

    await userDoc.set({
      'goals': existingGoals,
      'reminders': existingReminders,
    }, SetOptions(merge: true));

    setState(() {
      goals.clear();
      reminders.clear();
    });

    // Refetch goals after saving
    await fetchUserGoals();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goals and reminders updated!")),
    );
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget buildSectionTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0),
      child: Text(
        "$emoji $title",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Besom',
        ),
      ),
    );
  }

  InputDecoration themedInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  buildSectionTitle("🎯", "Your Goals"),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: hasUserGoals
                                  ? userGoals
                                      .map((g) => Chip(label: Text(g)))
                                      .toList()
                                  : predefinedGoals
                                      .map((g) => Chip(label: Text(g)))
                                      .toList(),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                          ],
                        ),

                  // Goal input section
                  buildSectionTitle("📝", "Add New Goals"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _goalController,
                          decoration:
                              themedInputDecoration("Enter a new goal..."),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (_goalController.text.trim().isNotEmpty) {
                            setState(() {
                              goals.add(_goalController.text.trim());
                              _goalController.clear();
                            });
                          }
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: goals.map((g) => Chip(label: Text(g))).toList(),
                  ),

                  buildSectionTitle("⏰", "Daily Reminders"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _reminderController,
                          decoration:
                              themedInputDecoration("e.g. Take supplements"),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.access_time, color: Colors.indigo),
                        onPressed: _pickTime,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (_reminderController.text.trim().isNotEmpty &&
                              _selectedTime != null) {
                            final formattedTime =
                                _selectedTime!.format(context);
                            final activity = _reminderController.text.trim();
                            setState(() {
                              reminders.add({
                                'title': activity,
                                'time': formattedTime,
                              });
                              _reminderController.clear();
                              _selectedTime = null;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: reminders
                        .map((r) =>
                            Chip(label: Text("${r['title']} - ${r['time']}")))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: const Text("Save All",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Besom')),
                    onPressed: _saveToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    _reminderController.dispose();
    super.dispose();
  }
}
