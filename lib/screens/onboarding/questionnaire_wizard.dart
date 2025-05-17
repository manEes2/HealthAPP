import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/core/utils/gemini_service.dart';

class QuestionnaireWizard extends StatefulWidget {
  const QuestionnaireWizard({super.key});

  @override
  State<QuestionnaireWizard> createState() => _QuestionnaireWizardState();
}

class _QuestionnaireWizardState extends State<QuestionnaireWizard> {
  final List<String> healthConditions = [
    "Diabetes",
    "High Blood Pressure",
    "Asthma",
    "Thyroid",
    "PCOS",
    "Heart Disease",
    "Other"
  ];

  final List<String> troubleFoods = [
    "Gluten",
    "Dairy",
    "Sugar",
    "Caffeine",
    "Soy",
    "Fried Foods"
  ];

  final List<String> bodyParts = [
    "Head",
    "Chest",
    "Back",
    "Stomach",
    "Joints",
    "Legs",
    "Arms",
  ];

  Set<String> selectedHealthConditions = {};
  Set<String> selectedTroubleFoods = {};
  Map<String, double> symptomSeverity = {};
  double fatRatio = 20.0;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return selectedHealthConditions.isNotEmpty;
      case 1:
        return selectedTroubleFoods.isNotEmpty;
      case 2:
        return symptomSeverity.isNotEmpty;
      default:
        return true;
    }
  }

  void _nextPage() {
    if (!_validateCurrentPage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete current section")),
      );
      return;
    }
    if (_currentPage < 3) {
      setState(() => _currentPage++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Save questionnaire data
      final questionnaireData = {
        "healthHistory": selectedHealthConditions.toList(),
        "troubleFoods": selectedTroubleFoods.toList(),
        "fatRatio": fatRatio,
        "symptomDetails": symptomSeverity,
      };

      await FirebaseFirestore.instance
          .collection("questionnaires")
          .doc(uid)
          .set(
            questionnaireData,
            SetOptions(merge: true),
          );

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "questionnaire_completed": true,
      }, SetOptions(merge: true));

      // ✅ Log before sending to Gemini
      print("Sending data to Gemini: $questionnaireData");

      // Generate AI Protocol
      final protocol = await GeminiService.generateProtocol(questionnaireData);
      print("Received protocol: $protocol");

      // Save Protocol
      await FirebaseFirestore.instance.collection("protocols").doc(uid).set(
          {"content": protocol, "generatedAt": FieldValue.serverTimestamp()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questionnaire submitted successfully")),
      );

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      print("Error during submission: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Onboarding (${_currentPage + 1}/4)")),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / 4),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMultiSelectPage("Select Health Conditions",
                    healthConditions, selectedHealthConditions),
                _buildMultiSelectPage(
                    "Select Trouble Foods", troubleFoods, selectedTroubleFoods),
                _buildSymptomPage(),
                _buildFatRatioPage()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(_currentPage == 3 ? "Finish" : "Next"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMultiSelectPage(
    String title,
    List<String> options,
    Set<String> selectedSet,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: options.map((item) {
              final selected = selectedSet.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                selectedColor: Colors.green,
                onSelected: (_) {
                  setState(() {
                    selected ? selectedSet.remove(item) : selectedSet.add(item);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Symptoms and Severity",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: bodyParts.map((part) {
              final selected = symptomSeverity.containsKey(part);
              return ChoiceChip(
                label: Text(part),
                selected: selected,
                selectedColor: Colors.green,
                onSelected: (_) {
                  setState(() {
                    selected
                        ? symptomSeverity.remove(part)
                        : symptomSeverity[part] = 5.0;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ...symptomSeverity.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${entry.key} Severity: ${entry.value.toStringAsFixed(1)}"),
                  Slider(
                    min: 1,
                    max: 10,
                    value: entry.value,
                    divisions: 9,
                    onChanged: (val) {
                      setState(() {
                        symptomSeverity[entry.key] = val;
                      });
                    },
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildFatRatioPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Estimate Your Fat Ratio (%)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("${fatRatio.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 16)),
          Slider(
            min: 0,
            max: 100,
            divisions: 100,
            value: fatRatio,
            label: fatRatio.toStringAsFixed(1),
            onChanged: (value) {
              setState(() => fatRatio = value);
            },
          )
        ],
      ),
    );
  }
}
