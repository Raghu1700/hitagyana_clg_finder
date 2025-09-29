import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'presentation/auth/simple_auth_screen.dart';
import 'presentation/saved_colleges_screen/saved_colleges_screen.dart';
import 'presentation/onboarding_flow/onboarding_flow.dart';
import 'presentation/main_navigation/main_navigation_wrapper.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FirebaseService.initialize();
  print('Firebase initialized successfully');
  await populateFirebaseWithColleges();
  await clearOldSavedColleges();
  runApp(const MyApp());
}

// Clear old saved college data to start fresh
Future<void> clearOldSavedColleges() async {
  try {
    // Don't clear anything - let onboarding and auth persist naturally
    print('✅ App initialized - checking existing session');
  } catch (e) {
    print('Error: $e');
  }
}

// Function to populate Firebase with college data
Future<void> populateFirebaseWithColleges() async {
  try {
    // Check if data already exists
    final existingColleges = await FirebaseService.getAllColleges();
    if (existingColleges.isNotEmpty) {
      print(
          '📚 Colleges already exist in database, clearing and adding fresh data');
      // Clear existing data to add fresh colleges
      for (var college in existingColleges) {
        await FirebaseService.deleteCollege(college['id']);
      }
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

    // College 4: NIT Trichy
    await FirebaseService.addCollege({
      'name': 'National Institute of Technology Tiruchirappalli',
      'shortName': 'NIT Trichy',
      'location': 'Tiruchirappalli, Tamil Nadu',
      'ranking': 5,
      'logo':
          'https://upload.wikimedia.org/wikipedia/en/8/8c/National_Institute_of_Technology%2C_Tiruchirappalli_logo.png',
      'tuitionFee': '₹1,50,000',
      'collegeFee': '₹30,000',
      'hostelFee': '₹60,000',
      'totalFee': '₹2,40,000',
      'courses': [
        'Computer Science & Engineering',
        'Mechanical Engineering',
        'Electrical & Electronics',
        'Civil Engineering',
        'Chemical Engineering',
        'Information Technology'
      ],
      'rating': 4.6,
      'reviewCount': 850,
      'website': 'https://www.nitt.edu',
      'established': 1964,
      'type': 'Government',
      'accreditation': 'NAAC A++',
      'campusSize': '800 acres',
      'studentCount': 6000,
      'facultyCount': 350,
      'placementRate': '92%',
      'averagePackage': '₹12,00,000',
      'facilities': [
        'Central Library',
        'Hostels',
        'Sports Complex',
        'Medical Center',
        'Wi-Fi Campus',
        'Research Labs'
      ],
      'admissions': {
        'entrance': 'JEE Main',
        'cutoff': 'Top 10,000 Ranks',
        'applicationDeadline': 'June 30, 2024'
      },
      'contact': {'email': 'info@nitt.edu', 'phone': '+91-431-2503000'},
      'description':
          'Premier engineering institution known for excellence in technical education and research.',
      'images': [
        'https://images.unsplash.com/photo-1562774053-701939374585?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=600&fit=crop'
      ]
    });

    // College 5: BITS Pilani
    await FirebaseService.addCollege({
      'name': 'Birla Institute of Technology and Science',
      'shortName': 'BITS Pilani',
      'location': 'Pilani, Rajasthan',
      'ranking': 3,
      'logo':
          'https://upload.wikimedia.org/wikipedia/en/5/5c/BITS_Pilani_Logo.png',
      'tuitionFee': '₹4,00,000',
      'collegeFee': '₹1,00,000',
      'hostelFee': '₹1,20,000',
      'totalFee': '₹6,20,000',
      'courses': [
        'Computer Science',
        'Mechanical Engineering',
        'Electrical & Electronics',
        'Chemical Engineering',
        'Civil Engineering',
        'Pharmacy'
      ],
      'rating': 4.7,
      'reviewCount': 1200,
      'website': 'https://www.bits-pilani.ac.in',
      'established': 1964,
      'type': 'Private',
      'accreditation': 'NAAC A++',
      'campusSize': '328 acres',
      'studentCount': 4500,
      'facultyCount': 400,
      'placementRate': '98%',
      'averagePackage': '₹15,00,000',
      'facilities': [
        'Central Library',
        'Hostels',
        'Sports Complex',
        'Medical Center',
        'Wi-Fi Campus',
        'Innovation Center'
      ],
      'admissions': {
        'entrance': 'BITSAT',
        'cutoff': 'Top 15,000 Ranks',
        'applicationDeadline': 'May 15, 2024'
      },
      'contact': {
        'email': 'info@bits-pilani.ac.in',
        'phone': '+91-1596-242210'
      },
      'description':
          'Premier private engineering institution with world-class facilities and excellent placement records.',
      'images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop'
      ]
    });

    print('✅ All colleges added successfully to Firebase!');
    print('🎉 Your app is now ready with college data!');

    // Add sample courses
    await _addSampleCourses();
  } catch (e) {
    print('❌ Error adding colleges to Firebase: $e');
  }
}

// Function to add sample courses
Future<void> _addSampleCourses() async {
  try {
    print('🚀 Adding sample courses to Firebase...');

    // Course 1: Flutter Development
    await FirebaseService.addCollege({
      'name': 'Complete Flutter Development Course',
      'instructor': 'Dr. Sarah Johnson',
      'category': 'Programming',
      'price': 2999,
      'originalPrice': 4999,
      'rating': 4.8,
      'reviewCount': 245,
      'description':
          'Master Flutter development from basics to advanced concepts. Build real-world mobile applications and learn best practices.',
      'image':
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&h=600&fit=crop',
      'features': [
        'Complete course materials',
        'Lifetime access',
        'Certificate of completion',
        '24/7 support',
        'Mobile and desktop access',
        'Real-world projects',
        'Code reviews'
      ],
      'duration': '8 weeks',
      'level': 'Beginner to Advanced',
      'language': 'English',
      'type': 'course'
    });

    // Course 2: Data Science
    await FirebaseService.addCollege({
      'name': 'Data Science & Machine Learning',
      'instructor': 'Prof. Michael Chen',
      'category': 'Data Science',
      'price': 3999,
      'originalPrice': 6999,
      'rating': 4.9,
      'reviewCount': 189,
      'description':
          'Learn data science, machine learning, and AI from industry experts. Work with real datasets and build predictive models.',
      'image':
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop',
      'features': [
        'Complete course materials',
        'Lifetime access',
        'Certificate of completion',
        '24/7 support',
        'Mobile and desktop access',
        'Real datasets',
        'Industry projects'
      ],
      'duration': '12 weeks',
      'level': 'Intermediate',
      'language': 'English',
      'type': 'course'
    });

    // Course 3: Digital Marketing
    await FirebaseService.addCollege({
      'name': 'Digital Marketing Masterclass',
      'instructor': 'Lisa Rodriguez',
      'category': 'Marketing',
      'price': 1999,
      'originalPrice': 3499,
      'rating': 4.7,
      'reviewCount': 156,
      'description':
          'Master digital marketing strategies, SEO, social media marketing, and analytics. Build your online presence.',
      'image':
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=600&fit=crop',
      'features': [
        'Complete course materials',
        'Lifetime access',
        'Certificate of completion',
        '24/7 support',
        'Mobile and desktop access',
        'Case studies',
        'Marketing tools'
      ],
      'duration': '6 weeks',
      'level': 'Beginner',
      'language': 'English',
      'type': 'course'
    });

    print('✅ All sample courses added successfully to Firebase!');
    
    // Add a mock enrollment for testing
    await _addMockEnrollment();
  } catch (e) {
    print('❌ Error adding sample courses to Firebase: $e');
  }
}

// Function to add mock enrollment
Future<void> _addMockEnrollment() async {
  try {
    print('🚀 Adding mock enrollment to Firebase...');
    
    // Check if user is logged in before adding enrollment
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Add enrollment for Python Programming course
      await FirebaseService.enrollInCourse(
        user.uid,
        '2', // Course ID for Python Programming
        'mock_payment_123',
      );
      print('✅ Mock enrollment added for Python Programming course!');
    } else {
      print('⚠️ No user logged in, skipping mock enrollment');
    }
    
    // Add sample classes to my_classes collection
    await _addSampleMyClasses();
  } catch (e) {
    print('❌ Error adding mock enrollment: $e');
  }
}

// Function to add sample classes to my_classes collection
Future<void> _addSampleMyClasses() async {
  try {
    print('🚀 Adding sample classes to my_classes collection...');
    
    // Check if classes already exist
    final existingClasses = await FirebaseService.getMyClasses();
    if (existingClasses.isNotEmpty) {
      print('⚠️ My classes already exist, skipping...');
      return;
    }
    
    // Class 1: Python Programming Bootcamp
    await FirebaseService.addMyClass({
      'name': 'Python Programming Bootcamp',
      'instructor': 'Michael Chen',
      'image': 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400',
      'rating': 4.9,
      'category': 'Technology',
      'price': 4999,
      'progress': 35,
      'description': 'Master Python programming with hands-on projects and real-world applications.',
      'enrolledAt': FieldValue.serverTimestamp(),
      'zoomMeetingId': '987 654 3210',
      'zoomMeetingLink': 'https://zoom.us/j/9876543210?pwd=xyz789',
      'zoomPassword': 'python123',
      'isRecurring': true,
      'recurringDays': ['Tuesday', 'Thursday'],
      'meetingTime': '8:00 PM - 9:30 PM',
      'timezone': 'IST',
    });
    
    // Class 2: Digital Art Fundamentals
    await FirebaseService.addMyClass({
      'name': 'Digital Art Fundamentals',
      'instructor': 'Sarah Johnson',
      'image': 'https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=400',
      'rating': 4.8,
      'category': 'Arts',
      'price': 2999,
      'progress': 65,
      'description': 'Learn the fundamentals of digital art creation using industry-standard tools and techniques.',
      'enrolledAt': FieldValue.serverTimestamp(),
      'zoomMeetingId': '123 456 7890',
      'zoomMeetingLink': 'https://zoom.us/j/1234567890?pwd=abc123',
      'zoomPassword': 'art2025',
      'isRecurring': true,
      'recurringDays': ['Monday', 'Wednesday', 'Friday'],
      'meetingTime': '7:00 PM - 8:30 PM',
      'timezone': 'IST',
    });
    
    print('✅ Sample classes added to my_classes collection!');
    
    // Add sample saved colleges
    await _addSampleSavedColleges();
  } catch (e) {
    print('❌ Error adding sample my classes: $e');
  }
}

// Function to add sample saved colleges to saved_colleges collection
Future<void> _addSampleSavedColleges() async {
  try {
    print('🚀 Adding sample saved colleges to saved_colleges collection...');
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ No user logged in, skipping saved colleges');
      return;
    }
    
    // Check if saved colleges already exist
    final existingSaved = await FirebaseService.getSavedCollegesData(user.uid);
    if (existingSaved.isNotEmpty) {
      print('⚠️ Saved colleges already exist, skipping...');
      return;
    }
    
    // Sample College 1: IIT Delhi
    await FirebaseService.addSavedCollege(user.uid, {
      'id': 'iit_delhi',
      'name': 'Indian Institute of Technology Delhi',
      'shortName': 'IIT Delhi',
      'location': 'New Delhi, Delhi',
      'ranking': 2,
      'logo': 'https://upload.wikimedia.org/wikipedia/en/f/fd/Indian_Institute_of_Technology_Delhi_Logo.svg',
      'totalFee': '₹3,75,000',
      'rating': 4.8,
      'reviewCount': 1250,
      'website': 'https://www.iitd.ac.in',
      'type': 'Government',
      'accreditation': 'NAAC A++',
      'images': [
        'https://images.unsplash.com/photo-1562774053-701939374585?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&h=600&fit=crop'
      ],
    });
    
    // Sample College 2: BITS Pilani
    await FirebaseService.addSavedCollege(user.uid, {
      'id': 'bits_pilani',
      'name': 'Birla Institute of Technology and Science',
      'shortName': 'BITS Pilani',
      'location': 'Pilani, Rajasthan',
      'ranking': 3,
      'logo': 'https://upload.wikimedia.org/wikipedia/en/5/5c/BITS_Pilani_Logo.png',
      'totalFee': '₹6,20,000',
      'rating': 4.7,
      'reviewCount': 1200,
      'website': 'https://www.bits-pilani.ac.in',
      'type': 'Private',
      'accreditation': 'NAAC A++',
      'images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop'
      ],
    });
    
    print('✅ Sample saved colleges added to saved_colleges collection!');
  } catch (e) {
    print('❌ Error adding sample saved colleges: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Hitagyana College Finder',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home:
              const AuthenticationWrapper(), // Direct to authentication wrapper
          routes: AppRoutes.routes,
        );
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Always go directly to dashboard - skip all checks
    return const MainNavigationWrapper();
  }
}
