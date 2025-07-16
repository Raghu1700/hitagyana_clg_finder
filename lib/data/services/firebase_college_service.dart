import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/college_model.dart';

class FirebaseCollegeService {
  // Singleton instance
  static final FirebaseCollegeService _instance =
      FirebaseCollegeService._internal();
  factory FirebaseCollegeService() => _instance;
  FirebaseCollegeService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _collegesCollection =
      FirebaseFirestore.instance.collection('colleges');

  // TEMPORARY: Clear the colleges collection
  Future<void> clearCollegesCollection() async {
    try {
      final snapshot = await _collegesCollection.get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Colleges collection cleared.');
    } catch (e) {
      print('Error clearing colleges collection: $e');
    }
  }

  // Initialize the colleges collection with default data if empty
  Future<void> initializeCollegesCollection() async {
    try {
      // Check if collection is empty
      final snapshot = await _collegesCollection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        // Collection is empty, add default colleges
        final defaultColleges = _getDefaultColleges();

        // Use batch write for better performance
        final batch = _firestore.batch();

        for (var college in defaultColleges) {
          final docRef = _collegesCollection.doc(college.id);
          batch.set(docRef, college.toJson());
        }

        // Commit the batch
        await batch.commit();
        print('Default colleges added to Firestore');
      } else {
        print('Colleges collection already has data');
      }
    } catch (e) {
      print('Error initializing colleges collection: $e');
      throw e;
    }
  }

  // Get all colleges
  Future<List<CollegeModel>> getAllColleges() async {
    try {
      final snapshot = await _collegesCollection.get();
      return snapshot.docs
          .map((doc) =>
              CollegeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all colleges: $e');
      throw e;
    }
  }

  // Get college by ID
  Future<CollegeModel?> getCollegeById(String id) async {
    try {
      final docSnapshot = await _collegesCollection.doc(id).get();

      if (docSnapshot.exists) {
        return CollegeModel.fromJson(
            docSnapshot.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting college by ID: $e');
      throw e;
    }
  }

  // Search colleges by name, location, or courses
  Future<List<CollegeModel>> searchColleges(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllColleges();
      }

      final lowercaseQuery = query.toLowerCase();

      // Get all colleges and filter in memory
      // In a production app, you would use Firestore queries or a search service like Algolia
      final allColleges = await getAllColleges();

      return allColleges.where((college) {
        return college.name.toLowerCase().contains(lowercaseQuery) ||
            college.location.toLowerCase().contains(lowercaseQuery) ||
            college.shortName.toLowerCase().contains(lowercaseQuery) ||
            college.courses
                .any((course) => course.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      print('Error searching colleges: $e');
      throw e;
    }
  }

  // Add a new college
  Future<void> addCollege(CollegeModel college) async {
    try {
      await _collegesCollection.doc(college.id).set(college.toJson());
    } catch (e) {
      print('Error adding college: $e');
      throw e;
    }
  }

  // Update an existing college
  Future<void> updateCollege(CollegeModel college) async {
    try {
      await _collegesCollection.doc(college.id).update(college.toJson());
    } catch (e) {
      print('Error updating college: $e');
      throw e;
    }
  }

  // Delete a college
  Future<void> deleteCollege(String id) async {
    try {
      await _collegesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting college: $e');
      throw e;
    }
  }

  // Filter colleges by various criteria
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
    try {
      // Start with all colleges
      List<CollegeModel> filteredColleges = await getAllColleges();

      // Apply filters
      if (location != null && location.isNotEmpty) {
        filteredColleges = filteredColleges
            .where((college) =>
                college.location.toLowerCase().contains(location.toLowerCase()))
            .toList();
      }

      if (type != null && type.isNotEmpty) {
        filteredColleges = filteredColleges
            .where(
                (college) => college.type.toLowerCase() == type.toLowerCase())
            .toList();
      }

      if (minRanking != null) {
        filteredColleges = filteredColleges
            .where((college) => college.ranking >= minRanking)
            .toList();
      }

      if (maxRanking != null) {
        filteredColleges = filteredColleges
            .where((college) => college.ranking <= maxRanking)
            .toList();
      }

      if (course != null && course.isNotEmpty) {
        filteredColleges = filteredColleges
            .where((college) => college.courses
                .any((c) => c.toLowerCase().contains(course.toLowerCase())))
            .toList();
      }

      if (minRating != null) {
        filteredColleges = filteredColleges
            .where((college) => college.rating >= minRating)
            .toList();
      }

      if (maxRating != null) {
        filteredColleges = filteredColleges
            .where((college) => college.rating <= maxRating)
            .toList();
      }

      if (priceRange != null && priceRange.isNotEmpty) {
        // Parse price range and filter
        // Example: "100000-300000"
        final parts = priceRange.split('-');
        if (parts.length == 2) {
          final minPrice = int.tryParse(parts[0]);
          final maxPrice = int.tryParse(parts[1]);

          if (minPrice != null && maxPrice != null) {
            filteredColleges = filteredColleges.where((college) {
              final totalFee = _extractFeeAmount(college.totalFee);
              return totalFee >= minPrice && totalFee <= maxPrice;
            }).toList();
          }
        }
      }

      return filteredColleges;
    } catch (e) {
      print('Error filtering colleges: $e');
      throw e;
    }
  }

  // Get recommended colleges based on category
  Future<List<CollegeModel>> getRecommendedColleges({String? category}) async {
    try {
      final allColleges = await getAllColleges();

      switch (category) {
        case 'Top Ranked':
          return allColleges.where((c) => c.ranking <= 10).toList()
            ..sort((a, b) => a.ranking.compareTo(b.ranking));
        case 'Affordable':
          return allColleges
              .where((c) => _extractFeeAmount(c.totalFee) <= 300000)
              .toList()
            ..sort((a, b) => _extractFeeAmount(a.totalFee)
                .compareTo(_extractFeeAmount(b.totalFee)));
        case 'Engineering':
          return allColleges
              .where((c) => c.courses.any(
                  (course) => course.toLowerCase().contains('engineering')))
              .toList();
        case 'Medical':
          return allColleges
              .where((c) => c.courses.any((course) =>
                  course.toLowerCase().contains('medical') ||
                  course.toLowerCase().contains('medicine')))
              .toList();
        case 'Management':
          return allColleges
              .where((c) => c.courses.any((course) =>
                  course.toLowerCase().contains('management') ||
                  course.toLowerCase().contains('mba')))
              .toList();
        default:
          return allColleges.take(10).toList();
      }
    } catch (e) {
      print('Error getting recommended colleges: $e');
      throw e;
    }
  }

  // Method to manually upload colleges to Firestore
  Future<void> uploadCollegesToFirestore() async {
    try {
      final defaultColleges = _getDefaultColleges();

      // Use batch write for better performance
      final batch = _firestore.batch();

      for (var college in defaultColleges) {
        final docRef = _collegesCollection.doc(college.id);
        batch.set(docRef, college.toJson());
      }

      // Commit the batch
      await batch.commit();
      print('Colleges uploaded to Firestore successfully');
      return;
    } catch (e) {
      print('Error uploading colleges to Firestore: $e');
      throw e;
    }
  }

  // Helper to extract fee amount
  int _extractFeeAmount(String fee) {
    final numericFee = fee.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericFee) ?? 0;
  }

  List<CollegeModel> _getDefaultColleges() {
    return [
      CollegeModel(
        id: 'clg001',
        name: 'Indian Institute of Technology, Bombay',
        shortName: 'IIT Bombay',
        location: 'Mumbai, Maharashtra',
        ranking: 1,
        logo: 'assets/images/no-image.jpg',
        tuitionFee: '₹2,00,000',
        collegeFee: '₹25,000',
        hostelFee: '₹50,000',
        totalFee: '₹8,00,000 - ₹9,00,000',
        courses: [
          'Computer Science & Engineering',
          'Mechanical Engineering',
          'Electrical Engineering',
          'Civil Engineering'
        ],
        rating: 4.8,
        website: 'https://www.iitb.ac.in/',
        established: 1958,
        type: 'Government',
        accreditation: 'NAAC A++',
        facilities: ['Hostel', 'Library', 'Sports Complex', 'Labs'],
        description:
            'IIT Bombay is a leading engineering and technology institute in India, known for its rigorous academics and research.',
        fees: {'tuition': 200000, 'other': 25000, 'hostel': 50000},
        images: ['assets/images/no-image.jpg'],
        contact: {'phone': '+91 22 2572 2545', 'email': 'pro@iitb.ac.in'},
        admissions: {'entrance': 'JEE Advanced', 'cutoff': 'Top Ranks'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CollegeModel(
        id: 'clg002',
        name: 'Vellore Institute of Technology',
        shortName: 'VIT Vellore',
        location: 'Vellore, Tamil Nadu',
        ranking: 8,
        logo: 'assets/images/no-image.jpg',
        tuitionFee: '₹1,95,000',
        collegeFee: '₹50,000',
        hostelFee: '₹1,00,000',
        totalFee: '₹7,80,000 - ₹19,80,000',
        courses: [
          'Information Technology',
          'Electronics & Communication',
          'Biotechnology',
          'Mechanical Engineering'
        ],
        rating: 4.5,
        website: 'https://vit.ac.in/',
        established: 1984,
        type: 'Private',
        accreditation: 'NAAC A++',
        facilities: ['Hostel', 'Wi-Fi', 'Gym', 'Cafeteria'],
        description:
            'VIT is a prestigious private university known for its flexible credit system and wide range of engineering programs.',
        fees: {'tuition': 195000, 'other': 50000, 'hostel': 100000},
        images: ['assets/images/no-image.jpg'],
        contact: {'phone': '+91 416 224 3091', 'email': 'info@vit.ac.in'},
        admissions: {'entrance': 'VITEEE', 'cutoff': 'Rank based'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
