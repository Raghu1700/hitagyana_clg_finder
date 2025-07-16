import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/college_model.dart';

class FirebaseSavedCollegesService {
  // Singleton instance
  static final FirebaseSavedCollegesService _instance =
      FirebaseSavedCollegesService._internal();
  factory FirebaseSavedCollegesService() => _instance;
  FirebaseSavedCollegesService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID or a default if not logged in
  String get _userId {
    return _auth.currentUser?.uid ?? 'anonymous';
  }

  // Reference to the user's saved colleges collection
  CollectionReference get _savedCollegesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('savedColleges');
  }

  // Reference to the colleges collection
  CollectionReference get _collegesCollection {
    return _firestore.collection('colleges');
  }

  // Save a college
  Future<void> saveCollege(String collegeId) async {
    try {
      // Get the college data first
      final collegeDoc = await _collegesCollection.doc(collegeId).get();

      if (!collegeDoc.exists) {
        throw Exception('College not found');
      }

      // Add to saved colleges with timestamp
      await _savedCollegesCollection.doc(collegeId).set({
        'collegeId': collegeId,
        'savedAt': FieldValue.serverTimestamp(),
        'collegeData': collegeDoc.data(), // Store a copy of the college data
      });
    } catch (e) {
      print('Error saving college: $e');
      throw e;
    }
  }

  // Remove a college from saved
  Future<void> unsaveCollege(String collegeId) async {
    try {
      await _savedCollegesCollection.doc(collegeId).delete();
    } catch (e) {
      print('Error removing saved college: $e');
      throw e;
    }
  }

  // Check if a college is saved
  Future<bool> isCollegeSaved(String collegeId) async {
    try {
      final docSnapshot = await _savedCollegesCollection.doc(collegeId).get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking if college is saved: $e');
      return false;
    }
  }

  // Get all saved colleges
  Future<List<CollegeModel>> getSavedColleges() async {
    try {
      final snapshot = await _savedCollegesCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final collegeData = data['collegeData'] as Map<String, dynamic>;
        return CollegeModel.fromJson(collegeData);
      }).toList();
    } catch (e) {
      print('Error getting saved colleges: $e');
      return [];
    }
  }

  // Get saved colleges with real-time updates
  Stream<List<CollegeModel>> getSavedCollegesStream() {
    try {
      return _savedCollegesCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final collegeData = data['collegeData'] as Map<String, dynamic>;
          return CollegeModel.fromJson(collegeData);
        }).toList();
      });
    } catch (e) {
      print('Error getting saved colleges stream: $e');
      return Stream.value([]);
    }
  }

  // Compare colleges
  Future<Map<String, dynamic>> compareColleges(List<String> collegeIds) async {
    try {
      if (collegeIds.length < 2) {
        throw Exception('Need at least 2 colleges to compare');
      }

      // Get all colleges to compare
      final colleges = <CollegeModel>[];

      for (final id in collegeIds) {
        final docSnapshot = await _collegesCollection.doc(id).get();
        if (docSnapshot.exists) {
          colleges.add(CollegeModel.fromJson(
              docSnapshot.data() as Map<String, dynamic>));
        }
      }

      if (colleges.length < 2) {
        throw Exception('Not enough valid colleges to compare');
      }

      // Create comparison data
      final comparison = <String, dynamic>{
        'colleges': colleges.map((c) => c.toJson()).toList(),
        'comparisonPoints': {
          'ranking':
              colleges.map((c) => {'id': c.id, 'value': c.ranking}).toList(),
          'fees':
              colleges.map((c) => {'id': c.id, 'value': c.totalFee}).toList(),
          'rating':
              colleges.map((c) => {'id': c.id, 'value': c.rating}).toList(),
          'facilities':
              colleges.map((c) => {'id': c.id, 'value': c.facilities}).toList(),
          'courses':
              colleges.map((c) => {'id': c.id, 'value': c.courses}).toList(),
        },
        'comparedAt': DateTime.now().toIso8601String(),
      };

      return comparison;
    } catch (e) {
      print('Error comparing colleges: $e');
      throw e;
    }
  }

  // Save comparison history
  Future<void> saveComparisonHistory(List<String> collegeIds) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('comparisonHistory')
          .add({
        'collegeIds': collegeIds,
        'comparedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving comparison history: $e');
      // Non-critical error, don't throw
    }
  }

  // Get comparison history
  Future<List<Map<String, dynamic>>> getComparisonHistory() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('comparisonHistory')
          .orderBy('comparedAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting comparison history: $e');
      return [];
    }
  }

  // Update college notes
  Future<void> updateCollegeNotes(String collegeId, String notes) async {
    try {
      await _savedCollegesCollection.doc(collegeId).update({
        'notes': notes,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating college notes: $e');
      throw e;
    }
  }
}
