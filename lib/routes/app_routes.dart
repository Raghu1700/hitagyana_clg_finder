import 'package:flutter/material.dart';

import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/college_details_screen/college_details_screen.dart';
import '../presentation/college_search_dashboard/college_search_dashboard.dart';
import '../presentation/extracurricular_classes_screen/extracurricular_classes_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/saved_colleges_screen/saved_colleges_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/firebase_test_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String login = '/login';
  static const String register = '/register';
  static const String extracurricularClassesScreen =
      '/extracurricular-classes-screen';
  static const String collegeSearchDashboard = '/college-search-dashboard';
  static const String savedCollegesScreen = '/saved-colleges-screen';
  static const String collegeDetailsScreen = '/college-details-screen';
  static const String firebaseTestScreen = '/firebase-test-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    extracurricularClassesScreen: (context) =>
        const ExtracurricularClassesScreen(),
    collegeSearchDashboard: (context) => const CollegeSearchDashboard(),
    savedCollegesScreen: (context) => const SavedCollegesScreen(),
    collegeDetailsScreen: (context) => const CollegeDetailsScreen(),
    firebaseTestScreen: (context) => const FirebaseTestScreen(),
    // TODO: Add your other routes here
  };
}
