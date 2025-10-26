import 'package:flutter/material.dart'; // For RangeValues

class User {
  String? name;
  String? email;
  String? phone;
  String? password;
  String? gender;
  String? interestedIn;
  DateTime? birthDate;
  String? location;
  RangeValues? ageRange;
  double? distanceRange;
  String? relationshipGoals;
  String? bio;
  List<String>? interests;
  String? lifestyle;
  String? profileImage;
  List<String>? verificationImages;

  // Default constructor
  User();

  // Named parameter constructor for creating from Firestore data
  User.fromData({
    this.name,
    this.email,
    this.phone,
    this.password,
    this.gender,
    this.interestedIn,
    this.birthDate,
    this.location,
    this.ageRange,
    this.distanceRange,
    this.relationshipGoals,
    this.bio,
    this.interests,
    this.lifestyle,
    this.profileImage,
    this.verificationImages,
  });
}
