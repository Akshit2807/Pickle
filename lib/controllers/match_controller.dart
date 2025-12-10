import 'package:get/get.dart';
import 'package:pickle/models/match.dart';
import 'package:pickle/services/api_service.dart';

/// Controller for managing matches
class MatchController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final RxList<Match> _matches = <Match>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _error = ''.obs;
  final RxString _sortBy = 'recent'.obs; // "recent" or "alphabetical"

  // Getters
  List<Match> get matches => _matches;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  String get error => _error.value;
  String get sortBy => _sortBy.value;
  int get unreadMatchesCount => _matches.where((m) => m.hasUnreadMessages).length;

  /// Set sort order
  void setSortBy(String value) {
    if (value == 'recent' || value == 'alphabetical') {
      _sortBy.value = value;
    }
  }

  /// Load matches
  Future<void> loadMatches({
    required String uid,
    bool refresh = false,
  }) async {
    if (_isLoading.value) return;

    try {
      if (refresh) {
        _currentPage.value = 1;
        _matches.clear();
        _hasMore.value = true;
      }

      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.getMatches(
        uid: uid,
        limit: 50,
        page: _currentPage.value,
        sortBy: _sortBy.value,
      );

      if (response.isSuccess && response.data != null) {
        final paginatedData = response.data!;
        
        if (refresh) {
          _matches.value = paginatedData.data;
        } else {
          _matches.addAll(paginatedData.data);
        }

        // Check if there are more pages
        _hasMore.value = 
            _currentPage.value < paginatedData.pagination.totalPages;
        
        if (_hasMore.value) {
          _currentPage.value++;
        }
      } else {
        _error.value = response.message ?? 'Failed to load matches';
        
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

  /// Get specific match details
  Future<Match?> getMatch({
    required String matchId,
    required String uid,
  }) async {
    try {
      final response = await _apiService.getMatch(
        matchId: matchId,
        uid: uid,
      );

      if (response.isSuccess && response.data != null) {
        return response.data;
      } else {
        _error.value = response.message ?? 'Failed to load match';
        return null;
      }
    } catch (e) {
      _error.value = e.toString();
      return null;
    }
  }

  /// Unmatch a user
  Future<bool> unmatch({
    required String matchId,
    required String uid,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.unmatch(
        matchId: matchId,
        uid: uid,
      );

      if (response.isSuccess) {
        // Remove from local list
        _matches.removeWhere((m) => m.id == matchId);
        
        _isLoading.value = false;
        
        Get.snackbar(
          'Success',
          'Successfully unmatched',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _error.value = response.message ?? 'Failed to unmatch';
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

  /// Update unread count for a match
  void updateUnreadCount(String matchId, int count) {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final match = _matches[index];
      _matches[index] = Match(
        id: match.id,
        matchedWith: match.matchedWith,
        matchedAt: match.matchedAt,
        lastMessageAt: match.lastMessageAt,
        unreadCount: count,
        messageCount: match.messageCount,
        isActive: match.isActive,
      );
    }
  }

  /// Refresh matches
  Future<void> refreshMatches(String uid) async {
    await loadMatches(uid: uid, refresh: true);
  }

  /// Load more matches (pagination)
  Future<void> loadMore(String uid) async {
    if (!_hasMore.value || _isLoading.value) return;
    await loadMatches(uid: uid, refresh: false);
  }

  /// Clear matches data
  void clear() {
    _matches.clear();
    _currentPage.value = 1;
    _hasMore.value = true;
    _error.value = '';
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
