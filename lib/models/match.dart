/// Match Model
class Match {
  final String id;
  final MatchedUser matchedWith;
  final String matchedAt;
  final String? lastMessageAt;
  final int? unreadCount;
  final int? messageCount;
  final bool? isActive;

  Match({
    required this.id,
    required this.matchedWith,
    required this.matchedAt,
    this.lastMessageAt,
    this.unreadCount,
    this.messageCount,
    this.isActive,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      matchedWith: MatchedUser.fromJson(json['matched_with']),
      matchedAt: json['matched_at'],
      lastMessageAt: json['last_message_at'],
      unreadCount: json['unread_count'],
      messageCount: json['message_count'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matched_with': matchedWith.toJson(),
      'matched_at': matchedAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (messageCount != null) 'message_count': messageCount,
      if (isActive != null) 'is_active': isActive,
    };
  }

  bool get hasUnreadMessages => (unreadCount ?? 0) > 0;
}

/// Matched User Model (simplified user info in match)
class MatchedUser {
  final String id;
  final String name;
  final int? age;
  final String? gender;
  final String? photoUrl;
  final String? bio;
  final List<String>? interests;
  final List<MatchedUserPhoto>? photos;

  MatchedUser({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.photoUrl,
    this.bio,
    this.interests,
    this.photos,
  });

  factory MatchedUser.fromJson(Map<String, dynamic> json) {
    return MatchedUser(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      photoUrl: json['photo_url'],
      bio: json['bio'],
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((p) => MatchedUserPhoto.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests,
      if (photos != null) 'photos': photos!.map((p) => p.toJson()).toList(),
    };
  }
}

/// Matched User Photo Model
class MatchedUserPhoto {
  final String id;
  final String url;
  final bool isPrimary;

  MatchedUserPhoto({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory MatchedUserPhoto.fromJson(Map<String, dynamic> json) {
    return MatchedUserPhoto(
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
