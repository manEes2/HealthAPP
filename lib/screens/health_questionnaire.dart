import 'package:flutter/material.dart';
import 'package:health_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/questionnaire_provider.dart';

class HealthQuestionnaireScreen extends StatefulWidget {
  const HealthQuestionnaireScreen({super.key});

  @override
  _HealthQuestionnaireScreenState createState() =>
      _HealthQuestionnaireScreenState();
}

class _HealthQuestionnaireScreenState extends State<HealthQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();

  final _healthHistoryController = TextEditingController();
  final _foodHistoryController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _troubleFoodsController = TextEditingController();
  double _fatRatio = 0.0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionnaireProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Health Questionnaire")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Health History"),
              TextFormField(
                controller: _healthHistoryController,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 10),
              Text("Food History"),
              TextFormField(
                controller: _foodHistoryController,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 10),
              Text("Body Symptoms & Severity"),
              TextFormField(
                controller: _symptomsController,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 10),
              Text("Trouble Foods"),
              TextFormField(
                controller: _troubleFoodsController,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 10),
              Text("Fat Ratio: ${_fatRatio.toStringAsFixed(1)}"),
              Slider(
                value: _fatRatio,
                min: 0,
                max: 100,
                divisions: 100,
                label: _fatRatio.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _fatRatio = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Submit"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    provider.updateHealthHistory(_healthHistoryController.text);
                    provider.updateFoodHistory(_foodHistoryController.text);
                    provider.updateSymptoms(_symptomsController.text);
                    provider.updateTroubleFoods(_troubleFoodsController.text);
                    provider.updateFatRatio(_fatRatio);

                    final userId =
                        Provider.of<AuthProvider>(context, listen: false)
                            .user
                            ?.uid;
                    if (userId != null) {
                      debugPrint("submitting questionnaire for user: $userId");
                      await provider.saveTofirestore(userId);

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Questionnaire Submitted")));
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
