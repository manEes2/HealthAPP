import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_app/core/const/app_color.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_app/models/quote_model.dart';
import 'package:health_app/services/quote_service.dart';
import 'package:lottie/lottie.dart';
import 'my_protocol_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quote> quotes = [];
  List<String> goals = [];
  List<String> reminders = [];
  Set<String> completedGoals = {};
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
    _fetchGoalsAndReminders();
  }

  void _fetchQuotes() async {
    try {
      final fetchedQuotes = await QuoteService.fetchQuotes();
      if (mounted) {
        setState(() => quotes = fetchedQuotes.take(10).toList());
        _startAutoScroll();
      }
    } catch (e) {
      print("Failed to fetch quotes: $e");
    }
  }

  void _fetchGoalsAndReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      final fetchedGoals = List<String>.from(data['goals'] ?? []);
      final fetchedReminders = List<String>.from(data['reminders'] ?? []);
      final fetchedCompleted = Set<String>.from(data['completedGoals'] ?? []);
      final lastUpdated = data['completedGoalsDate'] ?? '';

      setState(() {
        for (final goal in fetchedGoals) {
          if (!goals.contains(goal)) {
            goals.add(goal);
          }
        }

        for (final reminder in fetchedReminders) {
          if (!reminders.contains(reminder)) {
            reminders.add(reminder);
          }
        }

        completedGoals = lastUpdated == today ? fetchedCompleted : {};
      });
    }
  }

  Future<void> _saveCompletedGoals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Save current day's completed goals
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'completedGoals': completedGoals.toList(),
      'completedGoalsDate': today,
    }, SetOptions(merge: true));

    // Also log to daily history subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .doc(today)
        .set({
      'completedGoals': completedGoals.toList(),
      'date': today,
    });
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

  double _calculateProgress() {
    if (goals.isEmpty) return 0;

    // Count how many of the current goals are marked as completed
    final completed = goals.where((g) => completedGoals.contains(g)).length;
    return completed / goals.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return Scaffold(
      backgroundColor: medicalColors['primary'],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to Health Companion"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchGoalsAndReminders();
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Card(
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                  value: progress, color: Colors.green),
                              const SizedBox(height: 8),
                              Text(
                                  "${goals.where((g) => completedGoals.contains(g)).length}/${goals.length} goals achieved",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
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

              // Goals
              if (goals.isNotEmpty) ...[
                const Text("🎯 Your Goals",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...goals.map((goal) => CheckboxListTile(
                      title: Text(goal),
                      value: completedGoals.contains(goal),
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            completedGoals.add(goal);
                          } else {
                            completedGoals.remove(goal);
                          }
                          _saveCompletedGoals();
                        });
                      },
                    )),
                const SizedBox(height: 20),
              ],

              // Daily Reminders
              const Text("🕒 Today's Reminders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...reminders.map((item) => ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.green),
                    title: Text(item),
                  )),

              const SizedBox(height: 30),

              // Protocol Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/goals');
        },
        backgroundColor: Colors.green,
        tooltip: "Start a new activity",
        child: const Icon(Icons.sports_baseball, color: Colors.white, size: 30),
      ),
    );
  }
}
