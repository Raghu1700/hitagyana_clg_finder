import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Get user display name
  static String get userDisplayName {
    final user = _auth.currentUser;
    if (user == null) return 'Guest';
    // First try to get username from Firestore, fallback to email
    return user.email?.split('@').first ?? 'User';
  }

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        await UserService.createUserProfile(
          uid: credential.user!.uid,
          email: email,
          password: password,
          username: username,
        );

        // Sync local saved colleges with Firebase
        await _syncLocalSavedColleges(credential.user!.uid);
      }

      // Save user preference
      await _saveUserPreference(isAnonymous: false);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user document exists and update last login time
      if (credential.user != null) {
        await UserService.ensureUserDocument(
          credential.user!.uid,
          email: credential.user!.email,
          username: credential.user!.email?.split('@').first,
        );
        await UserService.updateLastLogin(credential.user!.uid);

        // Sync local saved colleges with Firebase
        await _syncLocalSavedColleges(credential.user!.uid);
      }

      // Save user preference
      await _saveUserPreference(isAnonymous: false);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Sign in anonymously (for browsing without account)
  static Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      // Save user preference
      await _saveUserPreference(isAnonymous: true);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Clear user preferences but keep app data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAnonymousUser');
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await UserService.deleteUserAccount(user.uid);

        // Clear all local data
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Convert anonymous account to permanent account
  static Future<UserCredential?> linkAnonymousAccount({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final user = currentUser;
      if (user == null || !user.isAnonymous) {
        throw 'No anonymous user to link';
      }

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link the credential
      final userCredential = await user.linkWithCredential(credential);

      // Update display name if provided
      if (username != null && username.isNotEmpty) {
        await userCredential.user?.updateDisplayName(username);
      }

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await UserService.createUserProfile(
          uid: userCredential.user!.uid,
          email: email,
          password: password,
          username: username,
        );

        // Sync local saved colleges to Firebase
        await _syncLocalSavedColleges(userCredential.user!.uid);
      }

      // Update user preference
      await _saveUserPreference(isAnonymous: false);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _getAuthError(e);
    }
  }

  // Add college to saved list
  static Future<bool> saveCollege(String collegeId) async {
    try {
      final user = currentUser;
      if (user == null) {
        // If not logged in, save locally only
        final prefs = await SharedPreferences.getInstance();
        final savedColleges = prefs.getStringList('savedColleges') ?? [];
        if (!savedColleges.contains(collegeId)) {
          savedColleges.add(collegeId);
          await prefs.setStringList('savedColleges', savedColleges);
        }
        return true;
      }

      if (user.isAnonymous) {
        // For anonymous users, save locally only
        final prefs = await SharedPreferences.getInstance();
        final savedColleges = prefs.getStringList('savedColleges') ?? [];
        if (!savedColleges.contains(collegeId)) {
          savedColleges.add(collegeId);
          await prefs.setStringList('savedColleges', savedColleges);
        }
        return true;
      } else {
        // For registered users, save to Firebase
        final success = await UserService.addSavedCollege(user.uid, collegeId);
        if (success) {
          // Also save locally for offline access
          final prefs = await SharedPreferences.getInstance();
          final savedColleges = prefs.getStringList('savedColleges') ?? [];
          if (!savedColleges.contains(collegeId)) {
            savedColleges.add(collegeId);
            await prefs.setStringList('savedColleges', savedColleges);
          }

          // Update saved colleges count
          await UserService.updateSavedCollegesCount(user.uid);
        }
        return success;
      }
    } catch (e) {
      print('Error saving college: $e');
      return false;
    }
  }

  // Remove college from saved list
  static Future<bool> unsaveCollege(String collegeId) async {
    try {
      final user = currentUser;
      if (user == null) {
        // If not logged in, remove from local only
        final prefs = await SharedPreferences.getInstance();
        final savedColleges = prefs.getStringList('savedColleges') ?? [];
        savedColleges.remove(collegeId);
        await prefs.setStringList('savedColleges', savedColleges);
        return true;
      }

      if (user.isAnonymous) {
        // For anonymous users, remove from local only
        final prefs = await SharedPreferences.getInstance();
        final savedColleges = prefs.getStringList('savedColleges') ?? [];
        savedColleges.remove(collegeId);
        await prefs.setStringList('savedColleges', savedColleges);
        return true;
      } else {
        // For registered users, remove from Firebase
        final success =
            await UserService.removeSavedCollege(user.uid, collegeId);
        if (success) {
          // Also remove from local storage
          final prefs = await SharedPreferences.getInstance();
          final savedColleges = prefs.getStringList('savedColleges') ?? [];
          savedColleges.remove(collegeId);
          await prefs.setStringList('savedColleges', savedColleges);

          // Update saved colleges count
          await UserService.updateSavedCollegesCount(user.uid);
        }
        return success;
      }
    } catch (e) {
      print('Error unsaving college: $e');
      return false;
    }
  }

  // Check if college is saved
  static Future<bool> isCollegeSaved(String collegeId) async {
    try {
      final user = currentUser;
      if (user == null || user.isAnonymous) {
        // Check local storage for non-registered users
        final prefs = await SharedPreferences.getInstance();
        final savedColleges = prefs.getStringList('savedColleges') ?? [];
        return savedColleges.contains(collegeId);
      } else {
        // Check Firebase for registered users
        return await UserService.isCollegeSaved(user.uid, collegeId);
      }
    } catch (e) {
      print('Error checking if college is saved: $e');
      return false;
    }
  }

  // Get all saved colleges
  static Future<List<String>> getSavedColleges() async {
    try {
      final user = currentUser;
      if (user == null || user.isAnonymous) {
        // Get from local storage for non-registered users
        final prefs = await SharedPreferences.getInstance();
        return prefs.getStringList('savedColleges') ?? [];
      } else {
        // Get from Firebase for registered users
        return await UserService.getSavedColleges(user.uid);
      }
    } catch (e) {
      print('Error getting saved colleges: $e');
      return [];
    }
  }

  // Check if user was anonymous
  static Future<bool> wasAnonymousUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAnonymousUser') ?? false;
  }

  // Private helper methods
  static Future<void> _saveUserPreference({required bool isAnonymous}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAnonymousUser', isAnonymous);
  }

  static Future<void> _syncLocalSavedColleges(String uid) async {
    try {
      // Get local saved colleges
      final prefs = await SharedPreferences.getInstance();
      final localSavedColleges = prefs.getStringList('savedColleges') ?? [];

      if (localSavedColleges.isNotEmpty) {
        // Sync with Firebase
        await UserService.syncLocalDataToFirebase(uid, localSavedColleges);
        print(
            '🔄 Synced ${localSavedColleges.length} local saved colleges to Firebase');
      }
    } catch (e) {
      print('Error syncing local saved colleges: $e');
    }
  }

  static String _getAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error'}';
    }
  }
}
