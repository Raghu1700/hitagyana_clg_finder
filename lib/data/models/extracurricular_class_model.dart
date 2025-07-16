class ExtracurricularClassModel {
  final String id;
  final String title;
  final String instructor;
  final String instructorImage;
  final String thumbnail;
  final String duration;
  final String skillLevel;
  final double rating;
  final int enrollmentCount;
  final String category;
  final String price;
  final String description;
  final List<String> prerequisites;
  final String schedule;
  final bool isEnrolled;
  final bool isWishlisted;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExtracurricularClassModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.instructorImage,
    required this.thumbnail,
    required this.duration,
    required this.skillLevel,
    required this.rating,
    required this.enrollmentCount,
    required this.category,
    required this.price,
    required this.description,
    required this.prerequisites,
    required this.schedule,
    required this.isEnrolled,
    required this.isWishlisted,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExtracurricularClassModel.fromJson(Map<String, dynamic> json) {
    return ExtracurricularClassModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      instructor: json['instructor'] ?? '',
      instructorImage: json['instructorImage'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
      skillLevel: json['skillLevel'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      enrollmentCount: json['enrollmentCount'] ?? 0,
      category: json['category'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      schedule: json['schedule'] ?? '',
      isEnrolled: json['isEnrolled'] ?? false,
      isWishlisted: json['isWishlisted'] ?? false,
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ??
          DateTime.now().add(Duration(days: 30)).toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'instructorImage': instructorImage,
      'thumbnail': thumbnail,
      'duration': duration,
      'skillLevel': skillLevel,
      'rating': rating,
      'enrollmentCount': enrollmentCount,
      'category': category,
      'price': price,
      'description': description,
      'prerequisites': prerequisites,
      'schedule': schedule,
      'isEnrolled': isEnrolled,
      'isWishlisted': isWishlisted,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExtracurricularClassModel copyWith({
    String? id,
    String? title,
    String? instructor,
    String? instructorImage,
    String? thumbnail,
    String? duration,
    String? skillLevel,
    double? rating,
    int? enrollmentCount,
    String? category,
    String? price,
    String? description,
    List<String>? prerequisites,
    String? schedule,
    bool? isEnrolled,
    bool? isWishlisted,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExtracurricularClassModel(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      instructorImage: instructorImage ?? this.instructorImage,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      skillLevel: skillLevel ?? this.skillLevel,
      rating: rating ?? this.rating,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      prerequisites: prerequisites ?? this.prerequisites,
      schedule: schedule ?? this.schedule,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
