import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Getters for Firebase instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseAnalytics get analytics => _analytics;

  // Method to test Firebase connection
  Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test successful',
      });

      // Read the document back
      final docSnapshot =
          await _firestore.collection('test').doc('connection').get();

      return docSnapshot.exists;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  // Method to get Firebase status
  Future<Map<String, dynamic>> getFirebaseStatus() async {
    final Map<String, dynamic> status = {};

    try {
      // Check if Firebase is initialized
      status['initialized'] = Firebase.apps.isNotEmpty;

      // Check Firestore connection
      status['firestore'] = await testConnection();

      // Check Authentication service
      status['auth'] = _auth.app != null;

      // Check Analytics service
      status['analytics'] = _analytics.app != null;
    } catch (e) {
      status['error'] = e.toString();
    }

    return status;
  }
}
