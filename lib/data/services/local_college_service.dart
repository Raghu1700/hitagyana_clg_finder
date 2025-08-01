import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/college_model.dart';

class LocalCollegeService {
  static const String _keyColleges = 'colleges';
  static const String _keySavedColleges = 'savedColleges';
  static const String _keyRecentSearches = 'recentSearches';
  static const String _keyCollegeFilters = 'collegeFilters';

  static LocalCollegeService? _instance;
  static LocalCollegeService get instance =>
      _instance ??= LocalCollegeService._internal();
  LocalCollegeService._internal();

  SharedPreferences? _prefs;
  List<CollegeModel> _colleges = [];
  List<String> _savedCollegeIds = [];

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadColleges();
    await _loadSavedColleges();
  }

  // College data methods
  Future<List<CollegeModel>> getAllColleges() async {
    await init();
    return List.from(_colleges);
  }

  Future<List<CollegeModel>> searchColleges(String query) async {
    await init();
    if (query.isEmpty) return _colleges;

    final lowercaseQuery = query.toLowerCase();
    return _colleges.where((college) {
      return college.name.toLowerCase().contains(lowercaseQuery) ||
          college.location.toLowerCase().contains(lowercaseQuery) ||
          college.shortName.toLowerCase().contains(lowercaseQuery) ||
          college.courses
              .any((course) => course.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<CollegeModel>> filterColleges({
    String? location,
    String? type,
    int? minRanking,
    int? maxRanking,
    String? course,
    double? minRating,
    double? maxRating,
    String? priceRange,
  }) async {
    await init();

    return _colleges.where((college) {
      if (location != null &&
          !college.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      if (type != null && college.type.toLowerCase() != type.toLowerCase()) {
        return false;
      }
      if (minRanking != null && college.ranking < minRanking) {
        return false;
      }
      if (maxRanking != null && college.ranking > maxRanking) {
        return false;
      }
      if (course != null &&
          !college.courses
              .any((c) => c.toLowerCase().contains(course.toLowerCase()))) {
        return false;
      }
      if (minRating != null && college.rating < minRating) {
        return false;
      }
      if (maxRating != null && college.rating > maxRating) {
        return false;
      }
      // Add price range filtering logic here if needed
      return true;
    }).toList();
  }

  Future<CollegeModel?> getCollegeById(String id) async {
    await init();
    try {
      return _colleges.firstWhere((college) => college.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<CollegeModel>> getCollegesByIds(List<String> ids) async {
    await init();
    return _colleges.where((college) => ids.contains(college.id)).toList();
  }

  Future<List<CollegeModel>> getRecommendedColleges({String? category}) async {
    await init();

    switch (category) {
      case 'Top Ranked':
        return _colleges.where((c) => c.ranking <= 10).toList()
          ..sort((a, b) => a.ranking.compareTo(b.ranking));
      case 'Affordable':
        return _colleges
            .where((c) => _extractFeeAmount(c.totalFee) <= 300000)
            .toList()
          ..sort((a, b) => _extractFeeAmount(a.totalFee)
              .compareTo(_extractFeeAmount(b.totalFee)));
      case 'Engineering':
        return _colleges
            .where((c) => c.courses
                .any((course) => course.toLowerCase().contains('engineering')))
            .toList();
      case 'Medical':
        return _colleges
            .where((c) => c.courses.any((course) =>
                course.toLowerCase().contains('medical') ||
                course.toLowerCase().contains('medicine')))
            .toList();
      case 'Management':
        return _colleges
            .where((c) => c.courses.any((course) =>
                course.toLowerCase().contains('management') ||
                course.toLowerCase().contains('mba')))
            .toList();
      default:
        return _colleges.take(10).toList();
    }
  }

  // Saved colleges methods
  Future<void> saveCollege(String collegeId) async {
    await init();
    if (!_savedCollegeIds.contains(collegeId)) {
      _savedCollegeIds.add(collegeId);
      await _prefs?.setStringList(_keySavedColleges, _savedCollegeIds);
    }
  }

  Future<void> unsaveCollege(String collegeId) async {
    await init();
    _savedCollegeIds.remove(collegeId);
    await _prefs?.setStringList(_keySavedColleges, _savedCollegeIds);
  }

  Future<bool> isCollegeSaved(String collegeId) async {
    await init();
    return _savedCollegeIds.contains(collegeId);
  }

  Future<List<CollegeModel>> getSavedColleges() async {
    await init();
    return _colleges
        .where((college) => _savedCollegeIds.contains(college.id))
        .toList();
  }

  // Search history methods
  Future<void> addRecentSearch(String query) async {
    await init();

    final recentSearches = _prefs?.getStringList(_keyRecentSearches) ?? [];

    // Remove if already exists
    recentSearches.remove(query);

    // Add to beginning
    recentSearches.insert(0, query);

    // Keep only last 10 searches
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    await _prefs?.setStringList(_keyRecentSearches, recentSearches);
  }

  Future<List<String>> getRecentSearches() async {
    await init();
    return _prefs?.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> clearRecentSearches() async {
    await init();
    await _prefs?.remove(_keyRecentSearches);
  }

  // Filter preferences
  Future<void> saveFilterPreferences(Map<String, dynamic> filters) async {
    await init();
    await _prefs?.setString(_keyCollegeFilters, jsonEncode(filters));
  }

  Future<Map<String, dynamic>> getFilterPreferences() async {
    await init();
    final filtersJson = _prefs?.getString(_keyCollegeFilters);
    if (filtersJson != null) {
      return jsonDecode(filtersJson);
    }
    return {};
  }

  // Private helper methods
  Future<void> _loadColleges() async {
    final collegesJson = _prefs?.getString(_keyColleges);
    if (collegesJson != null) {
      final collegesList = jsonDecode(collegesJson) as List;
      _colleges =
          collegesList.map((json) => CollegeModel.fromJson(json)).toList();
    } else {
      _colleges = _getDefaultColleges();
      await _saveColleges();
    }
  }

  Future<void> _saveColleges() async {
    final collegesJson = jsonEncode(_colleges.map((c) => c.toJson()).toList());
    await _prefs?.setString(_keyColleges, collegesJson);
  }

  Future<void> _loadSavedColleges() async {
    _savedCollegeIds = _prefs?.getStringList(_keySavedColleges) ?? [];
  }

  int _extractFeeAmount(String feeString) {
    return int.parse(feeString.replaceAll(RegExp(r'[₹,]'), ''));
  }

  List<CollegeModel> _getDefaultColleges() {
    return [
      CollegeModel(
        id: '1',
        name: 'Indian Institute of Technology Delhi',
        shortName: 'IIT Delhi',
        location: 'New Delhi, Delhi',
        ranking: 2,
        logo:
            'https://images.unsplash.com/photo-1562774053-701939374585?w=400&h=400&fit=crop',
        tuitionFee: '₹2,50,000',
        collegeFee: '₹50,000',
        hostelFee: '₹75,000',
        totalFee: '₹3,75,000',
        courses: ['Engineering', 'Technology', 'Computer Science'],
        rating: 4.8,
        website: 'https://www.iitd.ac.in',
        established: 1961,
        type: 'Government',
        accreditation: 'NAAC A++',
        facilities: ['Library', 'Sports Complex', 'Labs', 'Hostels'],
        description:
            'Premier engineering institute with world-class facilities.',
        fees: {'tuition': 250000, 'hostel': 75000, 'other': 50000},
        images: [
          'https://images.unsplash.com/photo-1562774053-701939374585?w=400&h=400&fit=crop'
        ],
        contact: {'phone': '+91-11-26597000', 'email': 'info@iitd.ac.in'},
        admissions: {'entrance': 'JEE Advanced', 'cutoff': 95},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: '2',
        name: 'Jawaharlal Nehru University',
        shortName: 'JNU',
        location: 'New Delhi, Delhi',
        ranking: 3,
        logo:
            'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&h=400&fit=crop',
        tuitionFee: '₹1,20,000',
        collegeFee: '₹25,000',
        hostelFee: '₹45,000',
        totalFee: '₹1,90,000',
        courses: ['Arts', 'Social Sciences', 'Languages'],
        rating: 4.6,
        website: 'https://www.jnu.ac.in',
        established: 1969,
        type: 'Government',
        accreditation: 'NAAC A+',
        facilities: ['Library', 'Research Centers', 'Hostels', 'Sports'],
        description: 'Leading university in liberal arts and social sciences.',
        fees: {'tuition': 120000, 'hostel': 45000, 'other': 25000},
        images: [
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&h=400&fit=crop'
        ],
        contact: {'phone': '+91-11-26704000', 'email': 'info@jnu.ac.in'},
        admissions: {'entrance': 'JNUEE', 'cutoff': 85},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: '3',
        name: 'Manipal Institute of Technology',
        shortName: 'MIT Manipal',
        location: 'Manipal, Karnataka',
        ranking: 15,
        logo:
            'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&h=400&fit=crop',
        tuitionFee: '₹3,50,000',
        collegeFee: '₹75,000',
        hostelFee: '₹1,20,000',
        totalFee: '₹5,45,000',
        courses: ['Engineering', 'Medicine', 'Management'],
        rating: 4.4,
        website: 'https://manipal.edu',
        established: 1957,
        type: 'Private',
        accreditation: 'NAAC A',
        facilities: ['Hospital', 'Labs', 'Sports Complex', 'Library'],
        description:
            'Comprehensive university with medical and engineering programs.',
        fees: {'tuition': 350000, 'hostel': 120000, 'other': 75000},
        images: [
          'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&h=400&fit=crop'
        ],
        contact: {'phone': '+91-820-2925000', 'email': 'info@manipal.edu'},
        admissions: {'entrance': 'MET', 'cutoff': 80},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: '4',
        name: 'Vellore Institute of Technology',
        shortName: 'VIT Vellore',
        location: 'Vellore, Tamil Nadu',
        ranking: 18,
        logo:
            'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=400&h=400&fit=crop',
        tuitionFee: '₹2,80,000',
        collegeFee: '₹60,000',
        hostelFee: '₹90,000',
        totalFee: '₹4,30,000',
        courses: ['Engineering', 'Technology', 'Applied Sciences'],
        rating: 4.3,
        website: 'https://vit.ac.in',
        established: 1984,
        type: 'Private',
        accreditation: 'NAAC A+',
        facilities: ['Research Centers', 'Innovation Hub', 'Sports', 'Library'],
        description:
            'Technology-focused university with strong industry connections.',
        fees: {'tuition': 280000, 'hostel': 90000, 'other': 60000},
        images: [
          'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=400&h=400&fit=crop'
        ],
        contact: {'phone': '+91-416-2243091', 'email': 'info@vit.ac.in'},
        admissions: {'entrance': 'VITEEE', 'cutoff': 75},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: '5',
        name: 'Birla Institute of Technology and Science',
        shortName: 'BITS Pilani',
        location: 'Pilani, Rajasthan',
        ranking: 8,
        logo:
            'https://images.unsplash.com/photo-1607237138185-eedd9c632b0b?w=400&h=400&fit=crop',
        tuitionFee: '₹4,20,000',
        collegeFee: '₹80,000',
        hostelFee: '₹1,50,000',
        totalFee: '₹6,50,000',
        courses: ['Engineering', 'Pharmacy', 'Management'],
        rating: 4.7,
        website: 'https://www.bits-pilani.ac.in',
        established: 1964,
        type: 'Private',
        accreditation: 'NAAC A',
        facilities: [
          'Research Labs',
          'Entrepreneurship Center',
          'Sports',
          'Library'
        ],
        description: 'Elite technical institute with strong alumni network.',
        fees: {'tuition': 420000, 'hostel': 150000, 'other': 80000},
        images: [
          'https://images.unsplash.com/photo-1607237138185-eedd9c632b0b?w=400&h=400&fit=crop'
        ],
        contact: {
          'phone': '+91-1596-242327',
          'email': 'info@bits-pilani.ac.in'
        },
        admissions: {'entrance': 'BITSAT', 'cutoff': 90},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: '6',
        name: 'Anna University',
        shortName: 'Anna Univ',
        location: 'Chennai, Tamil Nadu',
        ranking: 12,
        logo:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        tuitionFee: '₹1,80,000',
        collegeFee: '₹40,000',
        hostelFee: '₹65,000',
        totalFee: '₹2,85,000',
        courses: ['Engineering', 'Technology', 'Architecture'],
        rating: 4.2,
        website: 'https://www.annauniv.edu',
        established: 1978,
        type: 'Government',
        accreditation: 'NAAC A+',
        facilities: [
          'Research Centers',
          'Industry Partnerships',
          'Sports',
          'Library'
        ],
        description: 'Technical university with strong engineering programs.',
        fees: {'tuition': 180000, 'hostel': 65000, 'other': 40000},
        images: [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop'
        ],
        contact: {'phone': '+91-44-22359104', 'email': 'info@annauniv.edu'},
        admissions: {'entrance': 'TNEA', 'cutoff': 70},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Refresh/update data
  Future<void> refreshColleges() async {
    await init();
    // In a real app, this would fetch from server
    // For now, just update the timestamp
    for (int i = 0; i < _colleges.length; i++) {
      _colleges[i] = _colleges[i].copyWith(updatedAt: DateTime.now());
    }
    await _saveColleges();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await init();
    await _prefs?.remove(_keyColleges);
    await _prefs?.remove(_keySavedColleges);
    await _prefs?.remove(_keyRecentSearches);
    await _prefs?.remove(_keyCollegeFilters);
    _colleges.clear();
    _savedCollegeIds.clear();
  }
}
