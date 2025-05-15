import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quote_model.dart';

class QuoteService {
  static Future<List<Quote>> fetchQuotes() async {
    final response =
        await http.get(Uri.parse('https://zenquotes.io/api/quotes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quote.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load quotes");
    }
  }
}
