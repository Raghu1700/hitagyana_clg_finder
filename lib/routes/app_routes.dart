import 'package:flutter/material.dart';

import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/auth/simple_auth_screen.dart';
import '../presentation/college_details_screen/college_details_screen.dart';
import '../presentation/college_search_dashboard/college_search_dashboard.dart';
import '../presentation/extracurricular_classes_screen/extracurricular_classes_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/saved_colleges_screen/saved_colleges_screen.dart';

class AppRoutes {
  static const String initial = '/simple-auth-screen'; // Skip splash screen
  static const String onboardingFlow = '/onboarding-flow';
  static const String loginScreen = '/login-screen';
  static const String registerScreen = '/register-screen';
  static const String simpleAuthScreen = '/simple-auth-screen';
  static const String collegeSearchDashboard = '/college-search-dashboard';
  static const String collegeDetailsScreen = '/college-details-screen';
  static const String savedCollegesScreen = '/saved-colleges-screen';
  static const String extracurricularClassesScreen =
      '/extracurricular-classes-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SimpleAuthScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    loginScreen: (context) => const LoginScreen(),
    registerScreen: (context) => const RegisterScreen(),
    simpleAuthScreen: (context) => const SimpleAuthScreen(),
    collegeSearchDashboard: (context) => const CollegeSearchDashboard(),
    collegeDetailsScreen: (context) => const CollegeDetailsScreen(),
    savedCollegesScreen: (context) => const SavedCollegesScreen(),
    extracurricularClassesScreen: (context) =>
        const ExtracurricularClassesScreen(),
  };
}
