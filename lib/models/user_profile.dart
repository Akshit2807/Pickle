/// User Profile Model matching the backend API
class UserProfile {
  final String? id;
  final String uid; // Firebase UID
  final String name;
  final String email;
  final String birthdate; // YYYY-MM-DD format
  final String gender;
  final double latitude;
  final double longitude;
  final String? bio;
  final List<String>? interests;
  final List<ProfilePhoto>? photos;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;
  final int? likesCount;
  final int? matchesCount;
  final bool? isVerified;

  UserProfile({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.birthdate,
    required this.gender,
    required this.latitude,
    required this.longitude,
    this.bio,
    this.interests,
    this.photos,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.likesCount,
    this.matchesCount,
    this.isVerified,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      birthdate: json['birthdate'],
      gender: json['gender'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bio: json['bio'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List).map((p) => ProfilePhoto.fromJson(p)).toList()
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
      likesCount: json['likes_count'],
      matchesCount: json['matches_count'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'birthdate': birthdate,
      'gender': gender,
      'latitude': latitude,
      'longitude': longitude,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests,
      if (photos != null) 'photos': photos!.map((p) => p.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (likesCount != null) 'likes_count': likesCount,
      if (matchesCount != null) 'matches_count': matchesCount,
      if (isVerified != null) 'is_verified': isVerified,
    };
  }

  // Calculate age from birthdate
  int get age {
    final birthDate = DateTime.parse(birthdate);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? birthdate,
    String? gender,
    double? latitude,
    double? longitude,
    String? bio,
    List<String>? interests,
    List<ProfilePhoto>? photos,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
    int? likesCount,
    int? matchesCount,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      likesCount: likesCount ?? this.likesCount,
      matchesCount: matchesCount ?? this.matchesCount,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Profile Photo Model
class ProfilePhoto {
  final String id;
  final String url;
  final bool isPrimary;

  ProfilePhoto({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) {
    return ProfilePhoto(
      id: json['id'],
      url: json['url'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_primary': isPrimary,
    };
  }
}
