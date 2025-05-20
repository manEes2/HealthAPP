import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medical_medium_app/providers/auth_provider.dart';
import 'package:medical_medium_app/providers/questionnaire_provider.dart';
import 'package:medical_medium_app/screens/auth/login_screen.dart';
import 'package:medical_medium_app/screens/auth/register_screen.dart';
import 'package:medical_medium_app/screens/onboarding/questionnaire_wizard.dart';
import 'package:medical_medium_app/screens/personal/goals/provider/goal_provider.dart';
import 'package:medical_medium_app/screens/personal/goals/set_goal_screen.dart';
import 'package:medical_medium_app/screens/personal/goals/widgets/goal_history_screen.dart';
import 'package:medical_medium_app/screens/personal/mm_school/mm_school_screen.dart';
import 'package:medical_medium_app/screens/personal/progress/progress.dart';
import 'package:medical_medium_app/screens/splash/splash_screen.dart';

//import 'package:health_app/services/notification_service.dart';
import 'package:provider/provider.dart';

import 'screens/personal/community/shop_screen.dart';
import 'screens/personal/profile/profile_screen.dart';
import 'screens/personal/protocol/protocol_screen.dart';
import 'screens/personal/settings/setting_screen.dart';
import 'screens/personal/welcome_screen.dart';
//import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize notifications
  //NotificationService().initialize();

  //init timezone
  //tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionnaireProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medical Medium App',
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
          '/welcome': (context) => WelcomeScreen(),
          '/protocol': (context) => ProtocolScreen(),
          '/settings': (context) => SettingsScreen(),
          '/shop': (context) => ShopScreen(),
          '/school': (context) => MMSchoolScreen(),
          '/profile': (context) => ProfileScreen(),
        },
        home: SplashScreen(),
      ),
    );
  }
}
