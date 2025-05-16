import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/custom_loader.dart';

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
  List<String> reminders = [];

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'goals': goals,
      'reminders': reminders,
    }, SetOptions(merge: true));

    CustomLoader.show(context, text: "Saving...");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goals and reminders saved!")));
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Goals & Reminders")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("📝 Goals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration:
                        const InputDecoration(hintText: "Enter goal..."),
                  ),
                ),
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
            const SizedBox(height: 24),
            const Text("⏰ Daily Reminders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reminderController,
                    decoration: const InputDecoration(
                        hintText: "Activity (e.g. Take supplements)"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.blueGrey),
                  onPressed: _pickTime,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    if (_reminderController.text.trim().isNotEmpty &&
                        _selectedTime != null) {
                      final formattedTime = _selectedTime!.format(context);
                      setState(() {
                        reminders.add(
                            "${_reminderController.text.trim()} - $formattedTime");
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
              children: reminders.map((r) => Chip(label: Text(r))).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: const Text(
                "Save All",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: _saveToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
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
