import 'package:flutter/material.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:medical_medium_app/screens/personal/goals/provider/goal_provider.dart';
import 'package:provider/provider.dart';

class SetGoalsScreen extends StatefulWidget {
  const SetGoalsScreen({super.key});

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).fetchUserGoals();
    });
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
    final goalProvider = Provider.of<GoalProvider>(context);

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
                  goalProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: goalProvider.userGoals.isNotEmpty
                                  ? goalProvider.userGoals
                                      .map((g) => Chip(label: Text(g)))
                                      .toList()
                                  : goalProvider.predefinedGoals
                                      .map((g) => Chip(label: Text(g)))
                                      .toList(),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                          ],
                        ),
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
                            goalProvider.addGoal(_goalController.text.trim());
                            _goalController.clear();
                          }
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: goalProvider.goals
                        .map((g) => Chip(label: Text(g)))
                        .toList(),
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
                        onPressed: () => goalProvider.pickTime(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (_reminderController.text.trim().isNotEmpty &&
                              goalProvider.selectedTime != null) {
                            goalProvider.addReminder(
                              _reminderController.text.trim(),
                              goalProvider.selectedTime!,
                              context,
                            );
                            _reminderController.clear();
                          }
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: goalProvider.reminders
                        .map((r) =>
                            Chip(label: Text("${r['title']} - ${r['time']}")))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text("Save All",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Besom')),
                    onPressed: () async {
                      await goalProvider.saveAllToFirestore();
                    },
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
