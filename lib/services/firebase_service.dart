import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collegesCollection = 'colleges';

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBD55eE6WaEKP2Pxa7i3LntV-HGdzj9Xzc",
        authDomain: "hitagyana-clg-finder.firebaseapp.com",
        projectId: "hitagyana-clg-finder",
        storageBucket: "hitagyana-clg-finder.firebasestorage.app",
        messagingSenderId: "688136540466",
        appId: "1:688136540466:web:cdac5d71e268de1031872b",
        measurementId: "G-TL9YRXH0V7",
      ),
    );
  }

  // Helper function to safely convert dynamic list to string list
  static List<String> _safeCastToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  // Helper function to safely get string value
  static String _safeGetString(Map<String, dynamic> data, String key,
      [String defaultValue = '']) {
    return data[key]?.toString() ?? defaultValue;
  }

  // Get all colleges from Firestore
  static Future<List<Map<String, dynamic>>> getAllColleges() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collegesCollection)
          .orderBy('ranking', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Fix courses field to ensure it's a List<String>
        if (data['courses'] != null) {
          data['courses'] = _safeCastToStringList(data['courses']);
        }

        return data;
      }).toList();
    } catch (e) {
      print('Error getting colleges: $e');
      return [];
    }
  }

  // Search colleges by name, location, or courses
  static Future<List<Map<String, dynamic>>> searchColleges(String query) async {
    try {
      if (query.isEmpty) return await getAllColleges();

      final QuerySnapshot querySnapshot =
          await _firestore.collection(_collegesCollection).get();

      final List<Map<String, dynamic>> results = [];
      final lowercaseQuery = query.toLowerCase();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        final name = _safeGetString(data, 'name').toLowerCase();
        final location = _safeGetString(data, 'location').toLowerCase();
        final shortName = _safeGetString(data, 'shortName').toLowerCase();

        // Check if courses field exists and search in it
        bool courseMatch = false;
        if (data['courses'] != null) {
          final courses = _safeCastToStringList(data['courses']);
          data['courses'] = courses; // Fix the type
          courseMatch = courses
              .any((course) => course.toLowerCase().contains(lowercaseQuery));
        }

        if (name.contains(lowercaseQuery) ||
            location.contains(lowercaseQuery) ||
            shortName.contains(lowercaseQuery) ||
            courseMatch) {
          results.add(data);
        }
      }

      return results;
    } catch (e) {
      print('Error searching colleges: $e');
      return [];
    }
  }

  // Get colleges by category
  static Future<List<Map<String, dynamic>>> getCollegesByCategory(
      String category) async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection(_collegesCollection).get();

      final List<Map<String, dynamic>> results = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Fix courses field
        if (data['courses'] != null) {
          data['courses'] = _safeCastToStringList(data['courses']);
        }

        switch (category) {
          case 'Top Ranked':
            if (data['ranking'] != null && data['ranking'] <= 10) {
              results.add(data);
            }
            break;
          case 'Affordable':
            if (data['totalFee'] != null) {
              final feeString = _safeGetString(data, 'totalFee');
              final fee =
                  int.tryParse(feeString.replaceAll(RegExp(r'[₹,]'), '')) ?? 0;
              if (fee <= 300000) {
                results.add(data);
              }
            }
            break;
          case 'Engineering':
            if (data['courses'] != null) {
              final courses = _safeCastToStringList(data['courses']);
              if (courses.any(
                  (course) => course.toLowerCase().contains('engineering'))) {
                results.add(data);
              }
            }
            break;
          case 'Medical':
            if (data['courses'] != null) {
              final courses = _safeCastToStringList(data['courses']);
              if (courses.any((course) =>
                  course.toLowerCase().contains('medical') ||
                  course.toLowerCase().contains('medicine'))) {
                results.add(data);
              }
            }
            break;
          case 'Management':
            if (data['courses'] != null) {
              final courses = _safeCastToStringList(data['courses']);
              if (courses.any((course) =>
                  course.toLowerCase().contains('management') ||
                  course.toLowerCase().contains('mba'))) {
                results.add(data);
              }
            }
            break;
          default:
            results.add(data);
        }
      }

      // Sort results based on category
      if (category == 'Top Ranked' && results.isNotEmpty) {
        results.sort(
            (a, b) => (a['ranking'] ?? 999).compareTo(b['ranking'] ?? 999));
      } else if (category == 'Affordable' && results.isNotEmpty) {
        results.sort((a, b) {
          final aFee = int.tryParse(_safeGetString(a, 'totalFee')
                  .replaceAll(RegExp(r'[₹,]'), '')) ??
              0;
          final bFee = int.tryParse(_safeGetString(b, 'totalFee')
                  .replaceAll(RegExp(r'[₹,]'), '')) ??
              0;
          return aFee.compareTo(bFee);
        });
      }

      return results;
    } catch (e) {
      print('Error getting colleges by category: $e');
      return [];
    }
  }

  // Add a college (for admin purposes)
  static Future<bool> addCollege(Map<String, dynamic> collegeData) async {
    try {
      await _firestore.collection(_collegesCollection).add(collegeData);
      return true;
    } catch (e) {
      print('Error adding college: $e');
      return false;
    }
  }

  // Update a college
  static Future<bool> updateCollege(
      String collegeId, Map<String, dynamic> collegeData) async {
    try {
      await _firestore
          .collection(_collegesCollection)
          .doc(collegeId)
          .update(collegeData);
      return true;
    } catch (e) {
      print('Error updating college: $e');
      return false;
    }
  }

  // Delete a college
  static Future<bool> deleteCollege(String collegeId) async {
    try {
      await _firestore.collection(_collegesCollection).doc(collegeId).delete();
      return true;
    } catch (e) {
      print('Error deleting college: $e');
      return false;
    }
  }
}
