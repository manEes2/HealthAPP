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
        String result =
            json['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return _sanitizeResponse(result);
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
You are a natural healing guide. Create a **personalized health protocol** using Markdown format based on the user's information:

- **Health History:** $healthHistory
- **Trouble Foods:** $troubleFoods
- **Fat Ratio:** $fatRatio%
- **Symptoms:** $symptoms

Please include:
- 2 healing food recipes with ingredients
- 3 lifestyle or habit improvement tips
- Use Markdown for formatting (headings, lists, bold)

Avoid any disclaimers or AI-sounding intros.
''';
  }

  static String _sanitizeResponse(String response) {
    String cleaned = response
        .replaceAll(RegExp(r'^(Okay, here.*?\n)+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\*\*Disclaimer:.*?\n+', dotAll: true), '')
        .trim();
    return cleaned;
  }

  static String _getFallbackProtocol(Map<String, dynamic> data) {
    final troubleFoods =
        (data['troubleFoods'] as List?)?.join(', ') ?? 'processed foods';
    return '''
## Basic Protocol

- Drink at least 8 glasses of water daily  
- Avoid $troubleFoods  
- Take a 30-minute walk every day  
- Eat fresh fruits and vegetables  
- Practice deep breathing or meditation for 10 minutes  
''';
  }
}
