import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_app/providers/auth_provider.dart';
import 'package:health_app/providers/questionnaire_provider.dart';
import 'package:health_app/screens/auth/login_screen.dart';
import 'package:health_app/screens/auth/register_screen.dart';
import 'package:health_app/screens/home_screen.dart';
import 'package:health_app/screens/onboarding/questionnaire_wizard.dart';
import 'package:health_app/screens/personal/goal_history_screen.dart';
import 'package:health_app/screens/personal/set_goal_screen.dart';
import 'package:health_app/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionnaireProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routes: {
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/onboarding': (context) => QuestionnaireWizard(),
          '/goals': (context) => SetGoalsScreen(),
          '/history': (context) => GoalHistoryScreen(),
        },
        home: SplashScreen(),
      ),
    );
  }
}
