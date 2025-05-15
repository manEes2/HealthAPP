import 'package:flutter/material.dart';
import 'package:health_app/common_widgets/animated_logo_loader.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/questionnaire_provider.dart';

class QuestionnaireWizard extends StatefulWidget {
  const QuestionnaireWizard({super.key});

  @override
  State<QuestionnaireWizard> createState() => _QuestionnaireWizardState();
}

class _QuestionnaireWizardState extends State<QuestionnaireWizard> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final _controllers = List.generate(4, (_) => TextEditingController());
  double _fatRatio = 0.0;

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 4) {
        setState(() => _currentPage++);
        _pageController.nextPage(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _submit();
      }
    }
  }

  Future<void> _submit() async {
    final provider = Provider.of<QuestionnaireProvider>(context, listen: false);
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;

    print(userId);

    provider.updateHealthHistory(_controllers[0].text);
    provider.updateFoodHistory(_controllers[1].text);
    provider.updateSymptoms(_controllers[2].text);
    provider.updateTroubleFoods(_controllers[3].text);
    provider.updateFatRatio(_fatRatio);

    if (userId != null) {
      await provider.saveTofirestore(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('questionnaire_completed', true);

      AnimatedLogoLoader.show(context);
      Navigator.of(context).pushReplacementNamed('/home');
      AnimatedLogoLoader.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      "Health History",
      "Food History",
      "Symptoms & Severity",
      "Trouble Foods",
      "Fat Ratio"
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Onboarding (${_currentPage + 1}/5)")),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / 5),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKeys[index],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Lottie.asset("assets/animations/health.json",
                            height: 150),
                        SizedBox(height: 10),
                        Text(titles[index],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        if (index < 4)
                          TextFormField(
                            controller: _controllers[index],
                            validator: (val) =>
                                val!.isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  "Enter your ${titles[index].toLowerCase()}",
                            ),
                          )
                        else
                          Column(
                            children: [
                              Text(
                                  "Fat Ratio: ${_fatRatio.toStringAsFixed(1)}%"),
                              Slider(
                                value: _fatRatio,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: _fatRatio.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() => _fatRatio = value);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  _currentPage < 4 ? "Next" : "Finish",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
