import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalAuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyCurrentUser = 'currentUser';
  static const String _keyRememberMe = 'rememberMe';
  static const String _keyUserCredentials = 'userCredentials';
  static const String _keyUsers = 'users';

  static LocalAuthService? _instance;
  static LocalAuthService get instance =>
      _instance ??= LocalAuthService._internal();
  LocalAuthService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Authentication methods
  Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<bool> login(String email, String password) async {
    await init();

    // Get stored users
    final users = await _getStoredUsers();

    // Check if user exists with correct credentials
    final userCredentials = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => <String, dynamic>{},
    );

    if (userCredentials.isNotEmpty) {
      // Create user model
      final user = UserModel(
        id: userCredentials['id'],
        email: userCredentials['email'],
        name: userCredentials['name'],
        profileImage: userCredentials['profileImage'] ?? '',
        createdAt: DateTime.parse(userCredentials['createdAt']),
        lastLoginAt: DateTime.now(),
        interests: List<String>.from(userCredentials['interests'] ?? []),
        preferences:
            Map<String, dynamic>.from(userCredentials['preferences'] ?? {}),
      );

      // Update last login
      await _updateUserLastLogin(user.id);

      // Set login state
      await _prefs?.setBool(_keyIsLoggedIn, true);
      await _prefs?.setString(_keyCurrentUser, jsonEncode(user.toJson()));

      return true;
    }

    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    await init();

    // Get stored users
    final users = await _getStoredUsers();

    // Check if user already exists
    final existingUser = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => <String, dynamic>{},
    );

    if (existingUser.isNotEmpty) {
      return false; // User already exists
    }

    // Create new user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'password': password,
      'name': name,
      'profileImage':
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
      'createdAt': DateTime.now().toIso8601String(),
      'interests': <String>[],
      'preferences': <String, dynamic>{},
    };

    // Add to users list
    users.add(newUser);
    await _prefs?.setString(_keyUsers, jsonEncode(users));

    // Log in the new user
    return await login(email, password);
  }

  Future<void> logout() async {
    await init();
    await _prefs?.setBool(_keyIsLoggedIn, false);
    await _prefs?.remove(_keyCurrentUser);
    await _prefs?.remove(_keyRememberMe);
  }

  Future<UserModel?> getCurrentUser() async {
    await init();
    final userJson = _prefs?.getString(_keyCurrentUser);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await init();

    // Update current user
    await _prefs?.setString(_keyCurrentUser, jsonEncode(user.toJson()));

    // Update in users list
    final users = await _getStoredUsers();
    final index = users.indexWhere((u) => u['id'] == user.id);
    if (index != -1) {
      users[index] = user.toJson()..['password'] = users[index]['password'];
      await _prefs?.setString(_keyUsers, jsonEncode(users));
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    await init();
    final user = await getCurrentUser();
    if (user == null) return false;

    final users = await _getStoredUsers();
    final userIndex = users.indexWhere((u) => u['id'] == user.id);

    if (userIndex != -1 && users[userIndex]['password'] == currentPassword) {
      users[userIndex]['password'] = newPassword;
      await _prefs?.setString(_keyUsers, jsonEncode(users));
      return true;
    }

    return false;
  }

  Future<bool> resetPassword(String email) async {
    await init();
    final users = await _getStoredUsers();
    final userIndex = users.indexWhere((u) => u['email'] == email);

    if (userIndex != -1) {
      // In a real app, you'd send an email. Here we'll just reset to a default password
      users[userIndex]['password'] = 'newpassword123';
      await _prefs?.setString(_keyUsers, jsonEncode(users));
      return true;
    }

    return false;
  }

  // Remember me functionality
  Future<void> setRememberMe(
      bool remember, String? email, String? password) async {
    await init();
    await _prefs?.setBool(_keyRememberMe, remember);
    if (remember && email != null && password != null) {
      await _prefs?.setString(
          _keyUserCredentials,
          jsonEncode({
            'email': email,
            'password': password,
          }));
    } else {
      await _prefs?.remove(_keyUserCredentials);
    }
  }

  Future<bool> getRememberMe() async {
    await init();
    return _prefs?.getBool(_keyRememberMe) ?? false;
  }

  Future<Map<String, String>?> getRememberedCredentials() async {
    await init();
    final credentialsJson = _prefs?.getString(_keyUserCredentials);
    if (credentialsJson != null) {
      final credentials = jsonDecode(credentialsJson);
      return {
        'email': credentials['email'],
        'password': credentials['password'],
      };
    }
    return null;
  }

  // Private helper methods
  Future<List<Map<String, dynamic>>> _getStoredUsers() async {
    final usersJson = _prefs?.getString(_keyUsers);
    if (usersJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(usersJson));
    }

    // Initialize with default users if none exist
    final defaultUsers = [
      {
        'id': '1',
        'email': 'demo@hitagyana.com',
        'password': 'demo123',
        'name': 'Demo User',
        'profileImage':
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
        'createdAt': DateTime.now().toIso8601String(),
        'interests': ['Technology', 'Engineering'],
        'preferences': {'theme': 'light', 'notifications': true},
      },
      {
        'id': '2',
        'email': 'student@example.com',
        'password': 'student123',
        'name': 'Student User',
        'profileImage':
            'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
        'createdAt': DateTime.now().toIso8601String(),
        'interests': ['Arts', 'Music'],
        'preferences': {'theme': 'light', 'notifications': true},
      },
    ];

    await _prefs?.setString(_keyUsers, jsonEncode(defaultUsers));
    return defaultUsers;
  }

  Future<void> _updateUserLastLogin(String userId) async {
    final users = await _getStoredUsers();
    final index = users.indexWhere((user) => user['id'] == userId);
    if (index != -1) {
      users[index]['lastLoginAt'] = DateTime.now().toIso8601String();
      await _prefs?.setString(_keyUsers, jsonEncode(users));
    }
  }

  // Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    await init();
    await _prefs?.clear();
  }
}
