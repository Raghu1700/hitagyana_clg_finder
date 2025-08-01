import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

import 'routes/app_routes.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // Initialize Firebase first
  await FirebaseService.initialize();
  print('Firebase initialized successfully');

  // 🚨 ONE-TIME DATA POPULATION - Add colleges to Firebase
  await populateFirebaseWithColleges();

  // Clear old saved colleges to ensure fresh start
  await clearOldSavedColleges();

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

// Clear old saved college data to start fresh
Future<void> clearOldSavedColleges() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasCleared = prefs.getBool('hasCleared_v2') ?? false;

    if (!hasCleared) {
      await prefs.remove('savedColleges');
      await prefs.setBool('hasCleared_v2', true);
      print('🧹 Cleared old saved colleges data');
    }
  } catch (e) {
    print('Error clearing old data: $e');
  }
}

// Function to populate Firebase with college data
Future<void> populateFirebaseWithColleges() async {
  try {
    // Check if data already exists
    final existingColleges = await FirebaseService.getAllColleges();
    if (existingColleges.isNotEmpty) {
      print('📚 Colleges already exist in database, skipping population');
      return;
    }

    print('🚀 Adding colleges to Firebase...');

    // College 1: IIT Delhi
    await FirebaseService.addCollege({
      'name': 'Indian Institute of Technology Delhi',
      'shortName': 'IIT Delhi',
      'location': 'New Delhi, Delhi',
      'ranking': 2,
      'logo':
          'https://upload.wikimedia.org/wikipedia/en/f/fd/Indian_Institute_of_Technology_Delhi_Logo.svg',
      'tuitionFee': '₹2,50,000',
      'collegeFee': '₹50,000',
      'hostelFee': '₹75,000',
      'totalFee': '₹3,75,000',
      'courses': [
        'Computer Science & Engineering',
        'Mechanical Engineering',
        'Electrical Engineering',
        'Civil Engineering',
        'Chemical Engineering'
      ],
      'rating': 4.8,
      'reviewCount': 1250,
      'website': 'https://www.iitd.ac.in',
      'established': 1961,
      'type': 'Government',
      'accreditation': 'NAAC A++',
      'campusSize': '320 acres',
      'studentCount': 8500,
      'facultyCount': 450,
      'placementRate': '95%',
      'averagePackage': '₹18,00,000',
      'facilities': [
        'Library',
        'Hostels',
        'Sports Complex',
        'Medical Center',
        'Wi-Fi Campus'
      ],
      'admissions': {
        'entrance': 'JEE Advanced',
        'cutoff': 'Top Ranks',
        'applicationDeadline': 'June 15, 2024'
      },
      'contact': {'email': 'info@iitd.ac.in', 'phone': '+91-11-26597000'},
      'description':
          'One of India\'s premier technological institutions, known for excellence in engineering and research.',
      'images': [
        'https://images.unsplash.com/photo-1562774053-701939374585?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=600&fit=crop'
      ]
    });

    // College 2: AIIMS Delhi
    await FirebaseService.addCollege({
      'name': 'All India Institute of Medical Sciences',
      'shortName': 'AIIMS Delhi',
      'location': 'New Delhi, Delhi',
      'ranking': 1,
      'logo':
          'https://upload.wikimedia.org/wikipedia/en/b/bb/All_India_Institute_of_Medical_Sciences%2C_New_Delhi_logo.png',
      'tuitionFee': '₹1,00,000',
      'collegeFee': '₹25,000',
      'hostelFee': '₹50,000',
      'totalFee': '₹1,75,000',
      'courses': [
        'Medicine',
        'Surgery',
        'Nursing',
        'Medical Research',
        'Allied Health Sciences'
      ],
      'rating': 4.9,
      'reviewCount': 850,
      'website': 'https://www.aiims.edu',
      'established': 1956,
      'type': 'Government',
      'accreditation': 'NAAC A++',
      'campusSize': '200 acres',
      'studentCount': 5000,
      'facultyCount': 800,
      'placementRate': '100%',
      'averagePackage': '₹20,00,000',
      'facilities': [
        'Hospital',
        'Research Labs',
        'Library',
        'Sports Complex',
        'Medical Museum'
      ],
      'admissions': {
        'entrance': 'NEET',
        'cutoff': 'Top Ranks',
        'applicationDeadline': 'May 15, 2024'
      },
      'contact': {'email': 'info@aiims.edu', 'phone': '+91-11-26588500'},
      'description':
          'Premier medical institution of India with world-class healthcare and medical education.',
      'images': [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=600&fit=crop'
      ]
    });

    // College 3: IIM Ahmedabad
    await FirebaseService.addCollege({
      'name': 'Indian Institute of Management Ahmedabad',
      'shortName': 'IIM Ahmedabad',
      'location': 'Ahmedabad, Gujarat',
      'ranking': 1,
      'logo':
          'https://upload.wikimedia.org/wikipedia/en/1/1c/Indian_Institute_of_Management_Ahmedabad_Logo.svg',
      'tuitionFee': '₹25,00,000',
      'collegeFee': '₹2,00,000',
      'hostelFee': '₹1,50,000',
      'totalFee': '₹28,50,000',
      'courses': [
        'MBA',
        'Management',
        'Post Graduate Programme',
        'Executive Education',
        'PhD Management'
      ],
      'rating': 4.8,
      'reviewCount': 950,
      'website': 'https://www.iima.ac.in',
      'established': 1961,
      'type': 'Government',
      'accreditation': 'AACSB',
      'campusSize': '110 acres',
      'studentCount': 1200,
      'facultyCount': 150,
      'placementRate': '100%',
      'averagePackage': '₹35,00,000',
      'facilities': [
        'Library',
        'Case Study Rooms',
        'Sports Complex',
        'Auditorium',
        'Computer Center'
      ],
      'admissions': {
        'entrance': 'CAT',
        'cutoff': 'Top Ranks',
        'applicationDeadline': 'November 30, 2024'
      },
      'contact': {'email': 'info@iima.ac.in', 'phone': '+91-79-6632-4658'},
      'description':
          'India\'s premier management institute known for excellence in management education and research.',
      'images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop'
      ]
    });

    print('✅ All colleges added successfully to Firebase!');
    print('🎉 Your app is now ready with college data!');
  } catch (e) {
    print('❌ Error adding colleges to Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Hitagyana College Finder',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
