import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/extracurricular_class_model.dart';

class LocalExtracurricularService {
  static const String _keyClasses = 'extracurricularClasses';
  static const String _keyEnrolledClasses = 'enrolledClasses';
  static const String _keyWishlistedClasses = 'wishlistedClasses';
  static const String _keyClassHistory = 'classHistory';
  static const String _keyClassPreferences = 'classPreferences';

  static LocalExtracurricularService? _instance;
  static LocalExtracurricularService get instance =>
      _instance ??= LocalExtracurricularService._internal();
  LocalExtracurricularService._internal();

  SharedPreferences? _prefs;
  List<ExtracurricularClassModel> _classes = [];
  List<String> _enrolledClassIds = [];
  List<String> _wishlistedClassIds = [];

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadClasses();
    await _loadEnrolledClasses();
    await _loadWishlistedClasses();
  }

  // Class data methods
  Future<List<ExtracurricularClassModel>> getAllClasses() async {
    await init();
    return List.from(_classes);
  }

  Future<List<ExtracurricularClassModel>> getClassesByCategory(
      String category) async {
    await init();
    if (category == 'All') return _classes;
    return _classes.where((cls) => cls.category == category).toList();
  }

  Future<List<ExtracurricularClassModel>> searchClasses(String query) async {
    await init();
    if (query.isEmpty) return _classes;

    final lowercaseQuery = query.toLowerCase();
    return _classes.where((cls) {
      return cls.title.toLowerCase().contains(lowercaseQuery) ||
          cls.instructor.toLowerCase().contains(lowercaseQuery) ||
          cls.category.toLowerCase().contains(lowercaseQuery) ||
          cls.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<ExtracurricularClassModel>> filterClasses({
    String? category,
    String? skillLevel,
    String? priceRange,
    double? minRating,
    double? maxRating,
    List<String>? tags,
  }) async {
    await init();

    return _classes.where((cls) {
      if (category != null && category != 'All' && cls.category != category) {
        return false;
      }
      if (skillLevel != null && cls.skillLevel != skillLevel) {
        return false;
      }
      if (minRating != null && cls.rating < minRating) {
        return false;
      }
      if (maxRating != null && cls.rating > maxRating) {
        return false;
      }
      if (tags != null && !tags.any((tag) => cls.tags.contains(tag))) {
        return false;
      }
      // Add price range filtering logic here if needed
      return true;
    }).toList();
  }

  Future<ExtracurricularClassModel?> getClassById(String id) async {
    await init();
    try {
      return _classes.firstWhere((cls) => cls.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    await init();
    final categories = <String>{'All'};
    for (final cls in _classes) {
      categories.add(cls.category);
    }
    return categories.toList();
  }

  // Enrollment methods
  Future<void> enrollInClass(String classId) async {
    await init();
    if (!_enrolledClassIds.contains(classId)) {
      _enrolledClassIds.add(classId);
      await _prefs?.setStringList(_keyEnrolledClasses, _enrolledClassIds);

      // Update class enrollment count
      final classIndex = _classes.indexWhere((cls) => cls.id == classId);
      if (classIndex != -1) {
        _classes[classIndex] = _classes[classIndex].copyWith(
          isEnrolled: true,
          enrollmentCount: _classes[classIndex].enrollmentCount + 1,
        );
        await _saveClasses();
      }
    }
  }

  Future<void> unenrollFromClass(String classId) async {
    await init();
    _enrolledClassIds.remove(classId);
    await _prefs?.setStringList(_keyEnrolledClasses, _enrolledClassIds);

    // Update class enrollment count
    final classIndex = _classes.indexWhere((cls) => cls.id == classId);
    if (classIndex != -1) {
      _classes[classIndex] = _classes[classIndex].copyWith(
        isEnrolled: false,
        enrollmentCount: _classes[classIndex].enrollmentCount - 1,
      );
      await _saveClasses();
    }
  }

  Future<bool> isEnrolledInClass(String classId) async {
    await init();
    return _enrolledClassIds.contains(classId);
  }

  Future<List<ExtracurricularClassModel>> getEnrolledClasses() async {
    await init();
    return _classes.where((cls) => _enrolledClassIds.contains(cls.id)).toList();
  }

  // Wishlist methods
  Future<void> addToWishlist(String classId) async {
    await init();
    if (!_wishlistedClassIds.contains(classId)) {
      _wishlistedClassIds.add(classId);
      await _prefs?.setStringList(_keyWishlistedClasses, _wishlistedClassIds);

      // Update class wishlist status
      final classIndex = _classes.indexWhere((cls) => cls.id == classId);
      if (classIndex != -1) {
        _classes[classIndex] =
            _classes[classIndex].copyWith(isWishlisted: true);
        await _saveClasses();
      }
    }
  }

  Future<void> removeFromWishlist(String classId) async {
    await init();
    _wishlistedClassIds.remove(classId);
    await _prefs?.setStringList(_keyWishlistedClasses, _wishlistedClassIds);

    // Update class wishlist status
    final classIndex = _classes.indexWhere((cls) => cls.id == classId);
    if (classIndex != -1) {
      _classes[classIndex] = _classes[classIndex].copyWith(isWishlisted: false);
      await _saveClasses();
    }
  }

  Future<bool> isInWishlist(String classId) async {
    await init();
    return _wishlistedClassIds.contains(classId);
  }

  Future<List<ExtracurricularClassModel>> getWishlistedClasses() async {
    await init();
    return _classes
        .where((cls) => _wishlistedClassIds.contains(cls.id))
        .toList();
  }

  // History and preferences
  Future<void> addToHistory(String classId) async {
    await init();

    final history = _prefs?.getStringList(_keyClassHistory) ?? [];

    // Remove if already exists
    history.remove(classId);

    // Add to beginning
    history.insert(0, classId);

    // Keep only last 50 items
    if (history.length > 50) {
      history.removeLast();
    }

    await _prefs?.setStringList(_keyClassHistory, history);
  }

  Future<List<ExtracurricularClassModel>> getClassHistory() async {
    await init();
    final historyIds = _prefs?.getStringList(_keyClassHistory) ?? [];
    return _classes.where((cls) => historyIds.contains(cls.id)).toList();
  }

  Future<void> saveClassPreferences(Map<String, dynamic> preferences) async {
    await init();
    await _prefs?.setString(_keyClassPreferences, jsonEncode(preferences));
  }

  Future<Map<String, dynamic>> getClassPreferences() async {
    await init();
    final preferencesJson = _prefs?.getString(_keyClassPreferences);
    if (preferencesJson != null) {
      return jsonDecode(preferencesJson);
    }
    return {};
  }

  // Recommendations
  Future<List<ExtracurricularClassModel>> getRecommendedClasses({
    String? userId,
    String? category,
    int limit = 10,
  }) async {
    await init();

    // Simple recommendation logic based on enrolled classes and ratings
    final enrolledClasses = await getEnrolledClasses();
    final enrolledCategories =
        enrolledClasses.map((cls) => cls.category).toSet();

    var recommendations = _classes.where((cls) {
      // Don't recommend already enrolled classes
      if (_enrolledClassIds.contains(cls.id)) return false;

      // Prefer classes in similar categories
      if (category != null) {
        return cls.category == category;
      }

      // Prefer highly rated classes
      return cls.rating >= 4.0;
    }).toList();

    // Sort by rating and enrollment count
    recommendations.sort((a, b) {
      final aScore = a.rating + (a.enrollmentCount / 1000);
      final bScore = b.rating + (b.enrollmentCount / 1000);
      return bScore.compareTo(aScore);
    });

    return recommendations.take(limit).toList();
  }

  // Private helper methods
  Future<void> _loadClasses() async {
    final classesJson = _prefs?.getString(_keyClasses);
    if (classesJson != null) {
      final classesList = jsonDecode(classesJson) as List;
      _classes = classesList
          .map((json) => ExtracurricularClassModel.fromJson(json))
          .toList();
    } else {
      _classes = _getDefaultClasses();
      await _saveClasses();
    }
  }

  Future<void> _saveClasses() async {
    final classesJson = jsonEncode(_classes.map((c) => c.toJson()).toList());
    await _prefs?.setString(_keyClasses, classesJson);
  }

  Future<void> _loadEnrolledClasses() async {
    _enrolledClassIds = _prefs?.getStringList(_keyEnrolledClasses) ?? [];
  }

  Future<void> _loadWishlistedClasses() async {
    _wishlistedClassIds = _prefs?.getStringList(_keyWishlistedClasses) ?? [];
  }

  List<ExtracurricularClassModel> _getDefaultClasses() {
    return [
      ExtracurricularClassModel(
        id: '1',
        title: 'Digital Art Fundamentals',
        instructor: 'Sarah Johnson',
        instructorImage:
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '6 weeks',
        skillLevel: 'Beginner',
        rating: 4.8,
        enrollmentCount: 1250,
        category: 'Arts',
        price: '₹2,999',
        description:
            'Learn the fundamentals of digital art creation using industry-standard tools and techniques.',
        prerequisites: ['Basic computer skills', 'Creative mindset'],
        schedule: 'Mon, Wed, Fri - 7:00 PM',
        isEnrolled: false,
        isWishlisted: false,
        startDate: DateTime.now().add(Duration(days: 7)),
        endDate: DateTime.now().add(Duration(days: 49)),
        tags: ['Digital Art', 'Creative', 'Beginner'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExtracurricularClassModel(
        id: '2',
        title: 'Python Programming Bootcamp',
        instructor: 'Michael Chen',
        instructorImage:
            'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '8 weeks',
        skillLevel: 'Intermediate',
        rating: 4.9,
        enrollmentCount: 2100,
        category: 'Technology',
        price: '₹4,999',
        description:
            'Master Python programming with hands-on projects and real-world applications.',
        prerequisites: [
          'Basic programming knowledge',
          'Computer with Python installed'
        ],
        schedule: 'Tue, Thu - 8:00 PM',
        isEnrolled: true,
        isWishlisted: false,
        startDate: DateTime.now().add(Duration(days: 3)),
        endDate: DateTime.now().add(Duration(days: 59)),
        tags: ['Python', 'Programming', 'Intermediate'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExtracurricularClassModel(
        id: '3',
        title: 'Basketball Training Academy',
        instructor: 'James Rodriguez',
        instructorImage:
            'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1752757/pexels-photo-1752757.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '12 weeks',
        skillLevel: 'All Levels',
        rating: 4.7,
        enrollmentCount: 850,
        category: 'Sports',
        price: '₹3,499',
        description:
            'Improve your basketball skills with professional coaching and structured training.',
        prerequisites: ['Basic fitness level', 'Basketball shoes'],
        schedule: 'Sat, Sun - 6:00 AM',
        isEnrolled: false,
        isWishlisted: true,
        startDate: DateTime.now().add(Duration(days: 5)),
        endDate: DateTime.now().add(Duration(days: 89)),
        tags: ['Basketball', 'Sports', 'Fitness'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExtracurricularClassModel(
        id: '4',
        title: 'Guitar Mastery Course',
        instructor: 'Emma Wilson',
        instructorImage:
            'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1407322/pexels-photo-1407322.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '10 weeks',
        skillLevel: 'Beginner',
        rating: 4.6,
        enrollmentCount: 1680,
        category: 'Music',
        price: '₹3,999',
        description:
            'Learn to play guitar from scratch with step-by-step lessons and practice sessions.',
        prerequisites: ['Acoustic or electric guitar', 'Pick and tuner'],
        schedule: 'Mon, Wed, Fri - 6:30 PM',
        isEnrolled: false,
        isWishlisted: false,
        startDate: DateTime.now().add(Duration(days: 10)),
        endDate: DateTime.now().add(Duration(days: 80)),
        tags: ['Guitar', 'Music', 'Beginner'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExtracurricularClassModel(
        id: '5',
        title: 'Leadership Excellence Program',
        instructor: 'David Kumar',
        instructorImage:
            'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1181396/pexels-photo-1181396.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '4 weeks',
        skillLevel: 'Advanced',
        rating: 4.9,
        enrollmentCount: 920,
        category: 'Leadership',
        price: '₹5,999',
        description:
            'Develop essential leadership skills for personal and professional growth.',
        prerequisites: ['Work experience', 'Team management exposure'],
        schedule: 'Tue, Thu - 7:30 PM',
        isEnrolled: true,
        isWishlisted: false,
        startDate: DateTime.now().add(Duration(days: 2)),
        endDate: DateTime.now().add(Duration(days: 30)),
        tags: ['Leadership', 'Management', 'Advanced'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ExtracurricularClassModel(
        id: '6',
        title: 'Watercolor Painting Workshop',
        instructor: 'Lisa Anderson',
        instructorImage:
            'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
        thumbnail:
            'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=400',
        duration: '5 weeks',
        skillLevel: 'Beginner',
        rating: 4.5,
        enrollmentCount: 640,
        category: 'Arts',
        price: '₹2,499',
        description:
            'Explore the beautiful world of watercolor painting with professional techniques.',
        prerequisites: ['Watercolor paints', 'Brushes and paper'],
        schedule: 'Sat - 10:00 AM',
        isEnrolled: false,
        isWishlisted: false,
        startDate: DateTime.now().add(Duration(days: 14)),
        endDate: DateTime.now().add(Duration(days: 49)),
        tags: ['Watercolor', 'Painting', 'Arts'],
        metadata: {'language': 'English', 'timezone': 'IST'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Refresh/update data
  Future<void> refreshClasses() async {
    await init();
    // In a real app, this would fetch from server
    // For now, just update the timestamp
    for (int i = 0; i < _classes.length; i++) {
      _classes[i] = _classes[i].copyWith(updatedAt: DateTime.now());
    }
    await _saveClasses();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await init();
    await _prefs?.remove(_keyClasses);
    await _prefs?.remove(_keyEnrolledClasses);
    await _prefs?.remove(_keyWishlistedClasses);
    await _prefs?.remove(_keyClassHistory);
    await _prefs?.remove(_keyClassPreferences);
    _classes.clear();
    _enrolledClassIds.clear();
    _wishlistedClassIds.clear();
  }
}
