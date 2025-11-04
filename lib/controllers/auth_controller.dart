import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:pickle/models/user.dart' as app_user;
import 'package:pickle/services/auth_service.dart';
import 'package:pickle/services/user_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Observable variables
  final Rx<firebase_auth.User?> _firebaseUser = Rx<firebase_auth.User?>(null);
  final Rx<app_user.User?> _user = Rx<app_user.User?>(null);
  final RxBool _isLoading = false.obs;
  final RxInt _currentStep = 0.obs;

  // Getters
  firebase_auth.User? get firebaseUser => _firebaseUser.value;
  app_user.User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  int get currentStep => _currentStep.value;
  bool get isLoggedIn => _firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Bind auth state changes
    _firebaseUser.bindStream(_authService.authStateChanges);

    // Listen to user changes and load user data
    ever(_firebaseUser, _onAuthStateChanged);
  }

  // Handle auth state changes
  void _onAuthStateChanged(firebase_auth.User? user) async {
    if (user != null) {
      // User is logged in, load user data from Firestore
      await loadUserData(user.uid);
    } else {
      // User is logged out
      _user.value = null;
    }
  }

  // Load user data from Firestore
  Future<void> loadUserData(String uid) async {
    try {
      _user.value = await _userService.getUser(uid);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required app_user.User userData,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authService.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      if (result['success']) {
        Get.snackbar(
          'Success',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Signup failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result['success']) {
        Get.snackbar(
          'Success',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user.value = null;
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _isLoading.value = true;

      final result = await _authService.resetPassword(email);

      if (result['success']) {
        Get.snackbar(
          'Success',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Update user data
  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      if (_firebaseUser.value == null) return;

      await _userService.updateUser(
        uid: _firebaseUser.value!.uid,
        data: data,
      );

      // Reload user data
      await loadUserData(_firebaseUser.value!.uid);

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update current user object (for signup flow)
  void setUser(app_user.User user) {
    _user.value = user;
  }

  // Navigate to next signup step
  void nextStep() {
    _currentStep.value++;
  }

  // Navigate to previous signup step
  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }

  // Reset signup flow
  void resetSignupFlow() {
    _currentStep.value = 0;
    _user.value = app_user.User();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;

      final result = await _authService.deleteAccount();

      if (result['success']) {
        Get.snackbar(
          'Success',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
