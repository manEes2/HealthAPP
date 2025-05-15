import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_app/models/quote_model.dart';
import 'package:health_app/services/quote_service.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'my_protocol_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quote> quotes = [];
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> reminders = const [
    "🌤️ Morning Walk - 7:00 AM",
    "🥤 Drink detox juice - 8:00 AM",
    "💊 Take supplement - 10:00 AM",
    "🧘‍♂️ Meditation - 6:00 PM",
  ];

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  void _fetchQuotes() async {
    try {
      final fetchedQuotes = await QuoteService.fetchQuotes();
      if (mounted) {
        setState(() => quotes = fetchedQuotes.take(10).toList()); // Limit to 10
        _startAutoScroll();
      }
    } catch (e) {
      print("Failed to fetch quotes: $e");
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients && quotes.isNotEmpty) {
        _currentPage = (_currentPage + 1) % quotes.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Health Companion"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, "/login");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Section
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Lottie.asset("assets/animations/progress.json",
                        width: 100, height: 100),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Progress",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(
                              value: 0.6, color: Colors.green),
                          const SizedBox(height: 8),
                          Text("6/10 goals achieved",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Motivation Quotes
            const Text("💬 Daily Motivation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: quotes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: quotes.length,
                      itemBuilder: (_, index) {
                        final quote = quotes[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "“${quote.quote}”\n— ${quote.author}",
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Daily Reminders
            const Text("🕒 Today's Reminders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...reminders.map((item) => ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: Text(item),
                )),

            const SizedBox(height: 30),

            // Protocol Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.local_hospital, color: Colors.white),
                label: const Text("View My Protocol",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyProtocolScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
