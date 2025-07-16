class UserModel {
  final String id;
  final String email;
  final String name;
  final String profileImage;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> interests;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.profileImage,
    required this.createdAt,
    required this.lastLoginAt,
    required this.interests,
    required this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(
          json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      interests: List<String>.from(json['interests'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'interests': interests,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? interests,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
    );
  }
}
