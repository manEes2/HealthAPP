import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medical_medium_app/core/const/app_color.dart';
import 'package:medical_medium_app/models/quote_model.dart';
import 'package:medical_medium_app/services/quote_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quote> quotes = [];
  List<String> goals = [];
  List<Map<String, dynamic>> reminders = [];
  Set<String> completedGoals = {};
  bool showGoals = true;
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to fetch data. Please try again later.")));
    }
  }

  void _fetchGoalsAndReminders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      final fetchedGoals = List<String>.from(data['goals'] ?? []);
      final fetchedReminders = List<Map<String, dynamic>>.from(data['reminders'] ?? []);
      final fetchedCompleted = Set<String>.from(data['completedGoals'] ?? []);
      final lastUpdated = data['completedGoalsDate'] ?? '';

      setState(() {
        goals = fetchedGoals;
        reminders = fetchedReminders;
        completedGoals = lastUpdated == today ? fetchedCompleted : {};
      });
    }
  }

  Future<void> _saveCompletedGoals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'completedGoals': completedGoals.toList(),
      'completedGoalsDate': today,
    }, SetOptions(merge: true));

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
    _timer?.cancel();
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

  void _deleteGoal(String goal) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      goals.remove(goal);
      completedGoals.remove(goal);
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'goals': goals,
      'completedGoals': completedGoals.toList(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted goal: "$goal"')),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  double _calculateProgress() {
    if (goals.isEmpty) return 0;
    final completed = goals.where((g) => completedGoals.contains(g)).length;
    return completed / goals.length;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();

    return SafeArea(
      child: Scaffold(
        backgroundColor: medicalColors['primary'],
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.fill,
              ),
            ),
            // Profile Button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.person, size: 30, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
            ),
            // Main Content
            RefreshIndicator(
              onRefresh: () async {
                _fetchGoalsAndReminders();
                setState(() {});
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40), // Space for profile button
                    // Progress Section
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      child: Card(
                        color: Colors.yellow[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Lottie.asset(
                                "assets/animations/progress.json",
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Today's Progress",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Besom',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: progress,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${goals.where((g) => completedGoals.contains(g)).length}/${goals.length} goals achieved",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: 'Besom',
                                      ),
                                    ),
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
                    const Text(
                      "💬 Daily Motivation",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Besom',
                      ),
                    ),
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.green[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text(
                                        "\"${quote.quote}\"\n— ${quote.author}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                        ),
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
                      GestureDetector(
                        onTap: () => setState(() => showGoals = !showGoals),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "🎯 Your Goals",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Besom',
                              ),
                            ),
                            Icon(showGoals ? Icons.expand_less : Icons.expand_more),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (showGoals)
                        ...goals.map(
                          (goal) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            leading: Checkbox(
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
                            ),
                            title: Text(
                              goal,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Besom',
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGoal(goal),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // Daily Reminders
                    const Text(
                      "🕒 Today's Reminders",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Besom',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...reminders.map(
                      (item) => ListTile(
                        leading: const Icon(Icons.alarm, color: Colors.green),
                        title: Text(
                          item['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Besom',
                          ),
                        ),
                        subtitle: Text(
                          item['time'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Besom',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
