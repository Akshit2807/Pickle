import 'package:get/get.dart';
import 'package:pickle/models/user_profile.dart';
import 'package:pickle/models/api_response.dart';
import 'package:pickle/services/api_service.dart';

/// Controller for managing user profile
class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final Rx<UserProfile?> _profile = Rx<UserProfile?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  UserProfile? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasProfile => _profile.value != null;

  /// Create user profile after Firebase auth
  Future<bool> createProfile({
    required String uid,
    required String name,
    required String email,
    required String birthdate,
    required String gender,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.createProfile(
        uid: uid,
        name: name,
        email: email,
        birthdate: birthdate,
        gender: gender,
        latitude: latitude,
        longitude: longitude,
      );

      if (response.isSuccess && response.data != null) {
        _profile.value = response.data;
        _isLoading.value = false;
        return true;
      } else {
        _error.value = response.message ?? 'Failed to create profile';
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return false;
    }
  }

  /// Load user's own profile
  Future<bool> loadProfile(String uid) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.getOwnProfile(uid);

      if (response.isSuccess && response.data != null) {
        _profile.value = response.data;
        _isLoading.value = false;
        return true;
      } else {
        _error.value = response.message ?? 'Failed to load profile';
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return false;
    }
  }

  /// Get another user's profile
  Future<ApiResponse<UserProfile>> getUserProfile({
    required String userId,
    required String currentUid,
  }) async {
    return await _apiService.getUserProfile(
      userId: userId,
      currentUid: currentUid,
    );
  }

  /// Update profile
  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? email,
    double? latitude,
    double? longitude,
    String? bio,
    List<String>? interests,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.updateProfile(
        uid: uid,
        name: name,
        email: email,
        latitude: latitude,
        longitude: longitude,
        bio: bio,
        interests: interests,
      );

      if (response.isSuccess && response.data != null) {
        _profile.value = response.data;
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to update profile';
        _isLoading.value = false;
        
        Get.snackbar(
          'Error',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return false;
    }
  }

  /// Deactivate profile
  Future<bool> deactivateProfile(String uid) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.deactivateProfile(uid);

      if (response.isSuccess) {
        _profile.value = null;
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'Profile deactivated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to deactivate profile';
        _isLoading.value = false;
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return false;
    }
  }

  /// Clear profile data
  void clearProfile() {
    _profile.value = null;
    _error.value = '';
  }

  @override
  void onClose() {
    clearProfile();
    super.onClose();
  }
}
