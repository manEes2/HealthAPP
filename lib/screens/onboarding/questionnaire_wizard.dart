import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/custom_loader.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:lottie/lottie.dart';
import 'package:health_app/services/gemini_service.dart';

class QuestionnaireWizard extends StatefulWidget {
  const QuestionnaireWizard({super.key});

  @override
  State<QuestionnaireWizard> createState() => _QuestionnaireWizardState();
}

class _QuestionnaireWizardState extends State<QuestionnaireWizard> {
  final List<String> healthConditions = [
    "Diabetes",
    "High Blood Pressure",
    "Cancer",
    "Kidney Disease",
    "Liver Disease",
    "Digestive Issues",
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
        "Processed Foods",
    "Alcohol",
    "Artificial Sweeteners"
  ];

  final List<String> bodyParts = [
    "Head",
    "Chest",
    "Back",
    "Stomach",
    "Joints",
    "Legs",
    "Arms",
    "Skin",
    "Eyes",
    "Ears",
    "Nose",
    "Mouth",
    "Throat",
    "Other"
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
      //loader
      CustomLoader.show(context, text: "Submitting...");

      final questionnaireData = {
        "healthHistory": selectedHealthConditions.toList(),
        "troubleFoods": selectedTroubleFoods.toList(),
        "fatRatio": fatRatio,
        "symptomDetails": symptomSeverity,
      };

      // Save questionnaire data to Firestore
      await FirebaseFirestore.instance
          .collection("questionnaires")
          .doc(uid)
          .set(questionnaireData, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "questionnaire_completed": true,
      }, SetOptions(merge: true));

      // Generate protocol using GeminiService
      final protocol = await GeminiService.generateProtocol(questionnaireData);

      // Save generated protocol to Firestore
      await FirebaseFirestore.instance.collection("protocols").doc(uid).set(
          {"content": protocol, "generatedAt": FieldValue.serverTimestamp()});

      // Hide loader
      CustomLoader.hide(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questionnaire submitted successfully")),
      );

      Navigator.pushReplacementNamed(context, "/welcome");
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
      backgroundColor: medicalColors['primary'],
      appBar: AppBar(
        title: Text("Step ${_currentPage + 1} of 4",
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Besom')),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 4,
            backgroundColor: Colors.green.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMultiSelectPage("Select Your Health Conditions",
                    healthConditions, selectedHealthConditions),
                _buildMultiSelectPage("Select Foods That Trouble You",
                    troubleFoods, selectedTroubleFoods),
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
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_currentPage == 3 ? "Finish" : "Next",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Besom')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMultiSelectPage(
      String title, List<String> options, Set<String> selectedSet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.yellow.shade50,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Besom')),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: options.map((item) {
                  final selected = selectedSet.contains(item);
                  return FilterChip(
                    label: Text(item,
                        style: TextStyle(
                          fontFamily: 'Besom',
                          fontSize: 16,
                        )),
                    selected: selected,
                    selectedColor: Colors.green.shade300,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black),
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (_) {
                      setState(() {
                        selected
                            ? selectedSet.remove(item)
                            : selectedSet.add(item);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.yellow.shade50,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text("Select Symptom Areas and Rate Severity",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Besom')),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: bodyParts.map((part) {
                  final selected = symptomSeverity.containsKey(part);
                  return ChoiceChip(
                    label: Text(part,
                        style: TextStyle(
                          fontFamily: 'Besom',
                          fontSize: 16,
                        )),
                    selected: selected,
                    selectedColor: Colors.green.shade300,
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
                        "${entry.key} Severity: ${entry.value.toStringAsFixed(1)}",
                        style: TextStyle(fontFamily: 'Besom', fontSize: 16),
                      ),
                      Slider(
                        min: 1,
                        max: 10,
                        value: entry.value,
                        activeColor: Colors.green.shade700,
                        divisions: 9,
                        label: entry.value.toStringAsFixed(1),
                        onChanged: (val) {
                          setState(() => symptomSeverity[entry.key] = val);
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFatRatioPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.yellow.shade50,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Estimate Your Fat Ratio (%)",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Besom')),
              const SizedBox(height: 20),
              Lottie.asset('assets/animations/motivation.json', height: 180),
              Text("${fatRatio.toStringAsFixed(1)}%",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600)),
              Slider(
                min: 0,
                max: 100,
                activeColor: Colors.green.shade700,
                value: fatRatio,
                divisions: 100,
                label: fatRatio.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => fatRatio = value);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
