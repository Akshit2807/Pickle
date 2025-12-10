import 'package:get/get.dart';
import 'package:pickle/models/swipe.dart';
import 'package:pickle/services/api_service.dart';
import 'package:pickle/controllers/discovery_controller.dart';

/// Controller for managing swipe actions
class SwipeController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final RxBool _isProcessing = false.obs;
  final RxString _error = ''.obs;
  final Rx<SwipeAction?> _lastSwipe = Rx<SwipeAction?>(null);

  // Getters
  bool get isProcessing => _isProcessing.value;
  String get error => _error.value;
  SwipeAction? get lastSwipe => _lastSwipe.value;
  bool get isMatch => _lastSwipe.value?.isMatch ?? false;

  /// Swipe like on a user
  Future<SwipeAction?> swipeLike({
    required String uid,
    required String swipedId,
  }) async {
    return await _performSwipe(
      uid: uid,
      swipedId: swipedId,
      action: 'like',
    );
  }

  /// Swipe pass on a user
  Future<SwipeAction?> swipePass({
    required String uid,
    required String swipedId,
  }) async {
    return await _performSwipe(
      uid: uid,
      swipedId: swipedId,
      action: 'pass',
    );
  }

  /// Perform swipe action
  Future<SwipeAction?> _performSwipe({
    required String uid,
    required String swipedId,
    required String action,
  }) async {
    if (_isProcessing.value) return null;

    try {
      _isProcessing.value = true;
      _error.value = '';

      final response = await _apiService.swipe(
        uid: uid,
        swipedId: swipedId,
        action: action,
      );

      if (response.isSuccess && response.data != null) {
        _lastSwipe.value = response.data;
        
        // Remove from discovery feed
        try {
          final discoveryController = Get.find<DiscoveryController>();
          discoveryController.removeUser(swipedId);
        } catch (e) {
          // Discovery controller not found, ignore
        }

        // Show match notification if it's a match
        if (response.data!.isMatch == true) {
          Get.snackbar(
            '🎉 It\'s a Match!',
            response.data!.message ?? 'You matched with someone!',
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        }

        _isProcessing.value = false;
        return response.data;
      } else {
        _error.value = response.message ?? 'Failed to process swipe';
        _isProcessing.value = false;
        
        Get.snackbar(
          'Error',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return null;
      }
    } catch (e) {
      _error.value = e.toString();
      _isProcessing.value = false;
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return null;
    }
  }

  /// Get swipe history
  Future<List<SwipeHistoryItem>?> getSwipeHistory({
    required String uid,
    int? limit,
    int? page,
    String? actionFilter,
  }) async {
    try {
      final response = await _apiService.getSwipeHistory(
        uid: uid,
        limit: limit,
        page: page,
        actionFilter: actionFilter,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.data;
      } else {
        _error.value = response.message ?? 'Failed to fetch swipe history';
        return null;
      }
    } catch (e) {
      _error.value = e.toString();
      return null;
    }
  }

  /// Clear swipe data
  void clear() {
    _lastSwipe.value = null;
    _error.value = '';
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
