import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionnaireProvider with ChangeNotifier {
  String healthHistory = "";
  String foodHistory = "";
  String bodySymptoms = "";
  String troubleFoods = "";
  double fatRatio = 0.0;

  void updateHealthHistory(String value) {
    healthHistory = value;
    notifyListeners();
  }

  void updateFoodHistory(String value) {
    foodHistory = value;
    notifyListeners();
  }

  void updateSymptoms(String value) {
    bodySymptoms = value;
    notifyListeners();
  }

  void updateTroubleFoods(String value) {
    troubleFoods = value;
    notifyListeners();
  }

  void updateFatRatio(double value) {
    fatRatio = value;
    notifyListeners();
  }

  Future<void> saveTofirestore(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('questionnaires')
          .doc(uid)
          .set({
        'healthHistory': healthHistory,
        'foodHistory': foodHistory,
        'bodySymptoms': bodySymptoms,
        'troubleFoods': troubleFoods,
        'fatRatio': fatRatio,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      //display error message like popup or snackbar
      print("Error saving questionnaire: $e");
    }
  }

  Future<Map<String, dynamic>?> getQuestionnaire(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('questionnaires')
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching questionnaire: $e");
      return null;
    }
  }
}
