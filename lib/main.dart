import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'data/services/firebase_college_service.dart';
import 'data/services/local_auth_service.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase services
    final collegeService = FirebaseCollegeService();
    // TEMPORARY: Clear existing college data to allow for re-seeding
    await collegeService.clearCollegesCollection();
    await collegeService.initializeCollegesCollection();

    // Initialize local services
    await LocalAuthService.instance.init();

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(MyApp());
  } catch (e) {
    print("Failed to initialize app: $e");
    // Use a MaterialApp to show the error
    runApp(MaterialApp(
      home: CustomErrorWidget(errorMessage: e.toString()),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sizer for responsive UI
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Hitagyana College Finder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
