import 'package:get/get.dart';
import 'package:pickle/models/safety.dart';
import 'package:pickle/services/api_service.dart';

/// Controller for managing safety features (block, report)
class SafetyController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final RxList<Block> _blockedUsers = <Block>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  List<Block> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  /// Block a user
  Future<bool> blockUser({
    required String uid,
    required String blockedId,
    String? reason,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.blockUser(
        uid: uid,
        blockedId: blockedId,
        reason: reason,
      );

      if (response.isSuccess && response.data != null) {
        // Add to local list
        _blockedUsers.add(response.data!);
        
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'User blocked successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to block user';
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
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser({
    required String blockId,
    required String uid,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.unblockUser(
        blockId: blockId,
        uid: uid,
      );

      if (response.isSuccess) {
        // Remove from local list
        _blockedUsers.removeWhere((b) => b.id == blockId);
        
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'User unblocked successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to unblock user';
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
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Load blocked users
  Future<void> loadBlockedUsers({
    required String uid,
    int? limit,
    int? page,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.getBlockedUsers(
        uid: uid,
        limit: limit,
        page: page,
      );

      if (response.isSuccess && response.data != null) {
        _blockedUsers.value = response.data!.data;
      } else {
        _error.value = response.message ?? 'Failed to load blocked users';
        
        Get.snackbar(
          'Error',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _error.value = e.toString();
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Report a user
  Future<bool> reportUser({
    required String uid,
    required String reportedId,
    required String reason,
    String? details,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.reportUser(
        uid: uid,
        reportedId: reportedId,
        reason: reason,
        details: details,
      );

      if (response.isSuccess && response.data != null) {
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'Report submitted successfully. Reference: ${response.data!.referenceId ?? 'N/A'}',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to submit report';
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
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Check if a user is blocked
  bool isUserBlocked(String userId) {
    return _blockedUsers.any((b) => b.blockedId == userId);
  }

  /// Clear safety data
  void clear() {
    _blockedUsers.clear();
    _error.value = '';
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
