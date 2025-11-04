import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pickle/models/user.dart' as app_user;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Create user document in Firestore
  Future<void> createUser({
    required String uid,
    required app_user.User userData,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).set({
        'email': userData.email,
        'name': userData.name,
        'phone': userData.phone,
        'gender': userData.gender,
        'interestedIn': userData.interestedIn,
        'birthDate': userData.birthDate?.toIso8601String(),
        'location': userData.location,
        'bio': userData.bio,
        'ageRangeMin': userData.ageRange?.start,
        'ageRangeMax': userData.ageRange?.end,
        'distanceRange': userData.distanceRange,
        'relationshipGoals': userData.relationshipGoals,
        'interests': userData.interests ?? [],
        'lifestyle': userData.lifestyle,
        'profileImage': userData.profileImage,
        'verificationImages': userData.verificationImages ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<app_user.User?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return _userFromFirestore(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Update user data in Firestore
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Convert User object fields properly
      Map<String, dynamic> updateData = {};

      data.forEach((key, value) {
        if (value != null) {
          if (key == 'birthDate' && value is DateTime) {
            updateData[key] = value.toIso8601String();
          } else if (key == 'ageRange' && value is RangeValues) {
            updateData['ageRangeMin'] = value.start;
            updateData['ageRangeMax'] = value.end;
          } else {
            updateData[key] = value;
          }
        }
      });

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_usersCollection).doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail if document doesn't exist yet
      // User document might not be created yet during initial login
    }
  }

  // Delete user from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Stream user data changes
  Stream<app_user.User?> streamUser(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return _userFromFirestore(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check required fields
        return data['name'] != null &&
            data['gender'] != null &&
            data['birthDate'] != null &&
            data['interestedIn'] != null &&
            data['profileImage'] != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Query users by filters (for matching)
  Future<List<app_user.User>> queryUsers({
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection)
          .where('isActive', isEqualTo: true);

      if (gender != null) {
        query = query.where('gender', isEqualTo: gender);
      }

      QuerySnapshot snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) => _userFromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to query users: ${e.toString()}');
    }
  }

  // Helper method to convert Firestore data to User model
  app_user.User _userFromFirestore(Map<String, dynamic> data) {
    return app_user.User.fromData(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      password: null, // Never store password in the model
      gender: data['gender'],
      interestedIn: data['interestedIn'],
      birthDate: data['birthDate'] != null
          ? DateTime.parse(data['birthDate'])
          : null,
      location: data['location'],
      bio: data['bio'],
      ageRange: (data['ageRangeMin'] != null && data['ageRangeMax'] != null)
          ? RangeValues(
              data['ageRangeMin'].toDouble(),
              data['ageRangeMax'].toDouble(),
            )
          : null,
      distanceRange: data['distanceRange']?.toDouble(),
      relationshipGoals: data['relationshipGoals'],
      interests: data['interests'] != null
          ? List<String>.from(data['interests'])
          : null,
      lifestyle: data['lifestyle'],
      profileImage: data['profileImage'],
      verificationImages: data['verificationImages'] != null
          ? List<String>.from(data['verificationImages'])
          : null,
    );
  }
}
