import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickle/models/user.dart';

class AuthController extends GetxController {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable properties
  final Rx<firebase_auth.User?> _firebaseUser = Rx<firebase_auth.User?>(null);
  final RxInt _currentStep = 0.obs;
  final RxBool _isLoading = false.obs;

  // Getters
  firebase_auth.User? get firebaseUser => _firebaseUser.value;
  bool get isLoggedIn => _firebaseUser.value != null;
  int get currentStep => _currentStep.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Bind auth state changes
    _firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Sign up method
  Future<bool> signUp({
    required User user,
  }) async {
    try {
      _isLoading.value = true;

      // Create user with email and password
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );

      if (credential.user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'gender': user.gender,
          'interestedIn': user.interestedIn,
          'birthDate': user.birthDate?.toIso8601String(),
          'location': user.location,
          'ageRangeStart': user.ageRange?.start,
          'ageRangeEnd': user.ageRange?.end,
          'distanceRange': user.distanceRange,
          'relationshipGoals': user.relationshipGoals,
          'bio': user.bio,
          'interests': user.interests,
          'lifestyle': user.lifestyle,
          'profileImage': user.profileImage,
          'verificationImages': user.verificationImages,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _isLoading.value = false;
        return true;
      }

      _isLoading.value = false;
      return false;
    } catch (e) {
      _isLoading.value = false;
      print('Sign up error: $e');

      // Handle specific Firebase errors
      if (e is firebase_auth.FirebaseAuthException) {
        String errorMessage = 'An error occurred during sign up';

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
        }

        Get.snackbar(
          'Sign Up Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF660033),
          colorText: Colors.white,
        );
      }

      return false;
    }
  }

  // Sign in method
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading.value = false;
      return credential.user != null;
    } catch (e) {
      _isLoading.value = false;
      print('Sign in error: $e');

      // Handle specific Firebase errors
      if (e is firebase_auth.FirebaseAuthException) {
        String errorMessage = 'An error occurred during sign in';

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
        }

        Get.snackbar(
          'Sign In Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF660033),
          colorText: Colors.white,
        );
      }

      return false;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF660033),
        colorText: Colors.white,
      );
    }
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset email sent. Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF660033),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Password reset error: $e');

      String errorMessage = 'Failed to send password reset email';

      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
        }
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF660033),
        colorText: Colors.white,
      );
    }
  }

  // Signup flow step management
  void nextStep() {
    if (_currentStep.value < 3) {
      _currentStep.value++;
    }
  }

  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }

  void resetSignupFlow() {
    _currentStep.value = 0;
  }

  // Get user data from Firestore
  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        return User.fromData(
          name: data['name'],
          email: data['email'],
          phone: data['phone'],
          gender: data['gender'],
          interestedIn: data['interestedIn'],
          birthDate: data['birthDate'] != null
              ? DateTime.parse(data['birthDate'])
              : null,
          location: data['location'],
          // ageRange: data['ageRangeStart'] != null && data['ageRangeEnd'] != null
          //     ? RangeValues(data['ageRangeStart'], data['ageRangeEnd'])
          //     : null,
          distanceRange: data['distanceRange']?.toDouble(),
          relationshipGoals: data['relationshipGoals'],
          bio: data['bio'],
          interests: List<String>.from(data['interests'] ?? []),
          lifestyle: data['lifestyle'],
          profileImage: data['profileImage'],
          verificationImages: List<String>.from(data['verificationImages'] ?? []),
        );
      }

      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Update user data error: $e');
      return false;
    }
  }
}
