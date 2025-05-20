// goal_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoalProvider extends ChangeNotifier {
  final TextEditingController goalController = TextEditingController();
  final TextEditingController reminderController = TextEditingController();
  TimeOfDay? selectedTime;

  List<String> goals = [];
  List<Map<String, String>> reminders = [];

  bool isLoading = true;
  List<String> userGoals = [];

  final List<String> predefinedGoals = [
    "Drink 8 glasses of water",
    "Walk 10,000 steps",
    "Meditate 10 minutes",
    "Eat 3 servings of vegetables",
    "Sleep 8 hours"
  ];

  GoalProvider() {
    fetchUserGoals();
  }

  Future<void> fetchUserGoals() async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();
        if (data != null) {
          userGoals = List<String>.from(data['goals'] ?? []);
          reminders = List<Map<String, String>>.from((data['reminders'] ?? [])
              .map((e) => Map<String, dynamic>.from(e)));
        }
      }
    } catch (e) {
      debugPrint("Error fetching goals/reminders: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addGoal(String goal) {
    if (goal.isNotEmpty) {
      goals.add(goal);
      goalController.clear();
      notifyListeners();
    }
  }

  void addReminder(String title, TimeOfDay time, BuildContext context) {
    reminders.add({'title': title, 'time': time.format(context)});
    reminderController.clear();
    selectedTime = null;
    notifyListeners();
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime = picked;
      notifyListeners();
    }
  }

  Future<void> saveAllToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    List<String> existingGoals = [];
    List<Map<String, String>> existingReminders = [];

    if (snapshot.exists) {
      final data = snapshot.data() ?? {};
      existingGoals = List<String>.from(data['goals'] ?? []);

      // Convert Firestore maps to String maps
      existingReminders = (data['reminders'] as List<dynamic>? ?? [])
          .map<Map<String, String>>((dynamic item) {
        final map = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
        return map.map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }).toList();
    }

    // Rest of your existing code remains the same
    for (final g in goals) {
      if (!existingGoals.contains(g)) {
        existingGoals.add(g);
      }
    }

    for (final r in reminders) {
      bool exists = existingReminders
          .any((e) => e['title'] == r['title'] && e['time'] == r['time']);
      if (!exists) {
        existingReminders.add(r);
      }
    }

    await userDoc.set({
      'goals': existingGoals,
      'reminders': existingReminders,
    }, SetOptions(merge: true));

    goals.clear();
    reminders.clear();
    fetchUserGoals();
  }

  @override
  void dispose() {
    goalController.dispose();
    reminderController.dispose();
    super.dispose();
  }
}
