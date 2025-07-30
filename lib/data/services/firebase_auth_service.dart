import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  static FirebaseAuthService get instance =>
      _instance ??= FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthService._internal();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if username is unique
  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    // Check username uniqueness
    if (!await isUsernameUnique(username)) {
      throw FirebaseAuthException(
        code: 'username-already-in-use',
        message: 'This username is already taken. Please choose another one.',
      );
    }

    // Create user with email and password
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store additional user data in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'username': username,
      'passwordHash': _hashPassword(password),
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'profileImage': '',
      'interests': [],
      'preferences': {},
    });

    return userCredential;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update last login timestamp
    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .update({'lastLoginAt': FieldValue.serverTimestamp()});

    return userCredential;
  }

  // Start phone number verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // Sign in with phone number verification code
  Future<UserCredential> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Check if this is a new user
    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!userDoc.exists) {
      // Store user data in Firestore for new users
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'phoneNumber': userCredential.user!.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'interests': [],
        'preferences': {},
      });
    } else {
      // Update last login for existing users
      await userDoc.reference
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
    }

    return userCredential;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateProfile({
    String? username,
    String? profileImage,
    List<String>? interests,
    Map<String, dynamic>? preferences,
  }) async {
    if (currentUser == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{};

    if (username != null) {
      if (!await isUsernameUnique(username)) {
        throw Exception('Username already taken');
      }
      updates['username'] = username;
    }

    if (profileImage != null) updates['profileImage'] = profileImage;
    if (interests != null) updates['interests'] = interests;
    if (preferences != null) updates['preferences'] = preferences;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(updates);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
} 