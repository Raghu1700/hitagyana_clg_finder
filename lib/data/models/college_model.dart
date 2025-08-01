class CollegeModel {
  final String id;
  final String name;
  final String shortName;
  final String location;
  final int ranking;
  final String logo;
  final String tuitionFee;
  final String collegeFee;
  final String hostelFee;
  final String totalFee;
  final List<String> courses;
  final double rating;
  final String website;
  final int established;
  final String type;
  final String accreditation;
  final List<String> facilities;
  final String description;
  final Map<String, dynamic> fees;
  final List<String> images;
  final Map<String, dynamic> contact;
  final Map<String, dynamic> admissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollegeModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.location,
    required this.ranking,
    required this.logo,
    required this.tuitionFee,
    required this.collegeFee,
    required this.hostelFee,
    required this.totalFee,
    required this.courses,
    required this.rating,
    required this.website,
    required this.established,
    required this.type,
    required this.accreditation,
    required this.facilities,
    required this.description,
    required this.fees,
    required this.images,
    required this.contact,
    required this.admissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      location: json['location'] ?? '',
      ranking: json['ranking'] ?? 0,
      logo: json['logo'] ?? '',
      tuitionFee: json['tuitionFee'] ?? '',
      collegeFee: json['collegeFee'] ?? '',
      hostelFee: json['hostelFee'] ?? '',
      totalFee: json['totalFee'] ?? '',
      courses: List<String>.from(json['courses'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      website: json['website'] ?? '',
      established: json['established'] ?? 0,
      type: json['type'] ?? '',
      accreditation: json['accreditation'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      description: json['description'] ?? '',
      fees: Map<String, dynamic>.from(json['fees'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      contact: Map<String, dynamic>.from(json['contact'] ?? {}),
      admissions: Map<String, dynamic>.from(json['admissions'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'location': location,
      'ranking': ranking,
      'logo': logo,
      'tuitionFee': tuitionFee,
      'collegeFee': collegeFee,
      'hostelFee': hostelFee,
      'totalFee': totalFee,
      'courses': courses,
      'rating': rating,
      'website': website,
      'established': established,
      'type': type,
      'accreditation': accreditation,
      'facilities': facilities,
      'description': description,
      'fees': fees,
      'images': images,
      'contact': contact,
      'admissions': admissions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CollegeModel copyWith({
    String? id,
    String? name,
    String? shortName,
    String? location,
    int? ranking,
    String? logo,
    String? tuitionFee,
    String? collegeFee,
    String? hostelFee,
    String? totalFee,
    List<String>? courses,
    double? rating,
    String? website,
    int? established,
    String? type,
    String? accreditation,
    List<String>? facilities,
    String? description,
    Map<String, dynamic>? fees,
    List<String>? images,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? admissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollegeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      location: location ?? this.location,
      ranking: ranking ?? this.ranking,
      logo: logo ?? this.logo,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      collegeFee: collegeFee ?? this.collegeFee,
      hostelFee: hostelFee ?? this.hostelFee,
      totalFee: totalFee ?? this.totalFee,
      courses: courses ?? this.courses,
      rating: rating ?? this.rating,
      website: website ?? this.website,
      established: established ?? this.established,
      type: type ?? this.type,
      accreditation: accreditation ?? this.accreditation,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      fees: fees ?? this.fees,
      images: images ?? this.images,
      contact: contact ?? this.contact,
      admissions: admissions ?? this.admissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
