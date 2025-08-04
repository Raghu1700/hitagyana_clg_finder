import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';

  // Ensure user document exists (for existing Firebase Auth users)
  static Future<bool> ensureUserDocument(String uid,
      {String? email, String? username}) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) {
        // Create user document for existing Firebase Auth user
        final userDoc = {
          'uid': uid,
          'email': email ?? '',
          'username': username ?? '',
          'hashedPassword': '', // Empty for existing Firebase Auth users
          'savedColleges': [], // Initialize empty saved colleges list
          'preferences': {
            'notifications': true,
            'emailUpdates': false,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isEmailVerified': false,
          'accountType': 'regular',
          'profileComplete': false,
        };

        await _firestore.collection(_usersCollection).doc(uid).set(userDoc);
        print('✅ User document created for existing Firebase user: $uid');
        return true;
      }

      return true;
    } catch (e) {
      print('❌ Error ensuring user document: $e');
      return false;
    }
  }

  // Create user profile in Firestore when they register
  static Future<bool> createUserProfile({
    required String uid,
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      // Hash the password for storage
      final hashedPassword = _hashPassword(password);

      final userDoc = {
        'uid': uid,
        'email': email,
        'username': username ?? '',
        'hashedPassword': hashedPassword, // Store hashed password
        'savedColleges': [], // Initialize empty saved colleges list
        'preferences': {
          'notifications': true,
          'emailUpdates': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'accountType': 'regular', // regular, premium, admin
        'profileComplete': false,
      };

      await _firestore.collection(_usersCollection).doc(uid).set(userDoc);
      print('✅ User profile created in Firebase for: $email');
      return true;
    } catch (e) {
      print('❌ Error creating user profile: $e');
      return false;
    }
  }

  // Update user's last login time
  static Future<void> updateLastLogin(String uid) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      await _firestore.collection(_usersCollection).doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Add college to user's saved list in Firebase
  static Future<bool> addSavedCollege(String uid, String collegeId) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      await _firestore.collection(_usersCollection).doc(uid).update({
        'savedColleges': FieldValue.arrayUnion([collegeId])
      });
      print('✅ College $collegeId added to saved list for user $uid');
      return true;
    } catch (e) {
      print('❌ Error adding saved college: $e');
      return false;
    }
  }

  // Remove college from user's saved list in Firebase
  static Future<bool> removeSavedCollege(String uid, String collegeId) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      await _firestore.collection(_usersCollection).doc(uid).update({
        'savedColleges': FieldValue.arrayRemove([collegeId])
      });
      print('✅ College $collegeId removed from saved list for user $uid');
      return true;
    } catch (e) {
      print('❌ Error removing saved college: $e');
      return false;
    }
  }

  // Get user's saved colleges
  static Future<List<String>> getSavedColleges(String uid) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final savedColleges = data['savedColleges'] as List<dynamic>?;
        return savedColleges?.map((id) => id.toString()).toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting saved colleges: $e');
      return [];
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      await _firestore.collection(_usersCollection).doc(uid).update(updates);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Verify password (for login validation)
  static Future<bool> verifyPassword(String email, String password) async {
    try {
      // Get user document by email
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final storedHashedPassword = userData['hashedPassword'] as String;
        final inputHashedPassword = _hashPassword(password);

        return storedHashedPassword == inputHashedPassword;
      }
      return false;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  // Delete user account and all data
  static Future<bool> deleteUserAccount(String uid) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection(_usersCollection).doc(uid).delete();

      // Delete Firebase Auth account
      await _auth.currentUser?.delete();

      print('✅ User account deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting user account: $e');
      return false;
    }
  }

  // Update user's saved colleges count (for analytics)
  static Future<void> updateSavedCollegesCount(String uid) async {
    try {
      final savedColleges = await getSavedColleges(uid);
      await _firestore.collection(_usersCollection).doc(uid).update({
        'savedCollegesCount': savedColleges.length,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating saved colleges count: $e');
    }
  }

  // Check if college is saved by user
  static Future<bool> isCollegeSaved(String uid, String collegeId) async {
    try {
      final savedColleges = await getSavedColleges(uid);
      return savedColleges.contains(collegeId);
    } catch (e) {
      print('Error checking if college is saved: $e');
      return false;
    }
  }

  // Private helper method to hash passwords
  static String _hashPassword(String password) {
    // Using SHA-256 for password hashing
    // In production, consider using more secure methods like bcrypt
    final bytes = utf8.encode(password + 'hitagyana_salt_2024'); // Adding salt
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      final userProfile = await getUserProfile(uid);
      final savedColleges = await getSavedColleges(uid);

      return {
        'savedCollegesCount': savedColleges.length,
        'accountAge': userProfile?['createdAt'] != null
            ? DateTime.now()
                .difference((userProfile!['createdAt'] as Timestamp).toDate())
                .inDays
            : 0,
        'lastLogin': userProfile?['lastLoginAt'],
        'accountType': userProfile?['accountType'] ?? 'regular',
        'profileComplete': userProfile?['profileComplete'] ?? false,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Sync local data with Firebase (for migration)
  static Future<void> syncLocalDataToFirebase(
      String uid, List<String> localSavedColleges) async {
    try {
      // Ensure user document exists first
      await ensureUserDocument(uid);

      // Get current saved colleges from Firebase
      final firebaseSavedColleges = await getSavedColleges(uid);

      // Merge local and Firebase data (avoid duplicates)
      final allSavedColleges =
          <String>{...firebaseSavedColleges, ...localSavedColleges}.toList();

      // Update Firebase with merged data
      await _firestore.collection(_usersCollection).doc(uid).update({
        'savedColleges': allSavedColleges,
        'lastSyncAt': FieldValue.serverTimestamp(),
      });

      print(
          '✅ Local data synced to Firebase. Total saved colleges: ${allSavedColleges.length}');
    } catch (e) {
      print('❌ Error syncing local data to Firebase: $e');
    }
  }
}
