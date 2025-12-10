import 'user_profile.dart';

/// Discovery/Potential Match Model
class DiscoveryUser {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double distanceKm;
  final List<ProfilePhoto> photos;
  final String? bio;
  final List<String>? interests;
  final bool isVerified;

  DiscoveryUser({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.distanceKm,
    required this.photos,
    this.bio,
    this.interests,
    required this.isVerified,
  });

  factory DiscoveryUser.fromJson(Map<String, dynamic> json) {
    return DiscoveryUser(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      distanceKm: (json['distance_km'] as num).toDouble(),
      photos: (json['photos'] as List)
          .map((p) => ProfilePhoto.fromJson(p))
          .toList(),
      bio: json['bio'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'distance_km': distanceKm,
      'photos': photos.map((p) => p.toJson()).toList(),
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests,
      'is_verified': isVerified,
    };
  }
}

/// Discovery Request Parameters
class DiscoveryParams {
  final String uid;
  final int? limit;
  final int? distanceKm;
  final int? minAge;
  final int? maxAge;
  final List<String>? genderPreference;
  final int? page;

  DiscoveryParams({
    required this.uid,
    this.limit,
    this.distanceKm,
    this.minAge,
    this.maxAge,
    this.genderPreference,
    this.page,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      if (limit != null) 'limit': limit,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (minAge != null) 'min_age': minAge,
      if (maxAge != null) 'max_age': maxAge,
      if (genderPreference != null) 'gender_preference': genderPreference,
      if (page != null) 'page': page,
    };
  }
}
