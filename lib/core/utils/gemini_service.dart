import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static final _apiKey = dotenv.env['GEMINI_API_KEY'];
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generateProtocol(Map<String, dynamic> data) async {
    try {
      final prompt = _buildPrompt(data);

      final response = await http.post(
        Uri.parse('$_url?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return json['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      } else {
        print("Gemini API Error: ${json['error']}");
        return _getFallbackProtocol(data);
      }
    } catch (e) {
      print('Error: $e');
      return _getFallbackProtocol(data);
    }
  }

  static String _buildPrompt(Map<String, dynamic> data) {
    final healthHistory = data['healthHistory'] ?? 'None';
    final troubleFoods = (data['troubleFoods'] as List?)?.join(', ') ?? 'None';
    final fatRatio = data['fatRatio'] ?? 'N/A';
    final symptoms = data['symptomDetails'] ?? 'None';

    return '''
Create a personalized health protocol for the user based on the following:

- Health History: $healthHistory
- Trouble Foods: $troubleFoods
- Fat Ratio: $fatRatio%
- Symptoms: $symptoms

Include:
- 2 healing recipes
- 3 lifestyle tips

Format the output using Markdown.
''';
  }

  static String _getFallbackProtocol(Map<String, dynamic> data) {
    final troubleFoods =
        (data['troubleFoods'] as List?)?.join(', ') ?? 'processed foods';
    return '''
## Basic Protocol

1. Drink at least 8 glasses of water daily  
2. Avoid $troubleFoods  
3. Take a 30-minute walk every day
''';
  }
}
