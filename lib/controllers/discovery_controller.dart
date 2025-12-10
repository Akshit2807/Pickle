import 'package:get/get.dart';
import 'package:pickle/models/discovery.dart';
import 'package:pickle/services/api_service.dart';

/// Controller for managing discovery/swipe feed
class DiscoveryController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final RxList<DiscoveryUser> _potentialMatches = <DiscoveryUser>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _error = ''.obs;

  // Discovery filters
  final RxInt _distanceKm = 50.obs;
  final RxInt _minAge = 18.obs;
  final RxInt _maxAge = 45.obs;
  final RxList<String> _genderPreference = <String>[].obs;

  // Getters
  List<DiscoveryUser> get potentialMatches => _potentialMatches;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  String get error => _error.value;
  int get distanceKm => _distanceKm.value;
  int get minAge => _minAge.value;
  int get maxAge => _maxAge.value;
  List<String> get genderPreference => _genderPreference;

  // Setters for filters
  void setDistanceKm(int value) => _distanceKm.value = value;
  void setMinAge(int value) => _minAge.value = value;
  void setMaxAge(int value) => _maxAge.value = value;
  void setGenderPreference(List<String> value) => _genderPreference.value = value;

  /// Load potential matches
  Future<void> loadPotentialMatches({
    required String uid,
    bool refresh = false,
  }) async {
    if (_isLoading.value) return;

    try {
      if (refresh) {
        _currentPage.value = 1;
        _potentialMatches.clear();
        _hasMore.value = true;
      }

      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.discover(
        uid: uid,
        limit: 20,
        distanceKm: _distanceKm.value,
        minAge: _minAge.value,
        maxAge: _maxAge.value,
        genderPreference: _genderPreference.isEmpty ? null : _genderPreference,
        page: _currentPage.value,
      );

      if (response.isSuccess && response.data != null) {
        final paginatedData = response.data!;
        
        if (refresh) {
          _potentialMatches.value = paginatedData.data;
        } else {
          _potentialMatches.addAll(paginatedData.data);
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

  /// Remove a user from potential matches (after swiping)
  void removeUser(String userId) {
    _potentialMatches.removeWhere((user) => user.id == userId);
  }

  /// Refresh discovery feed
  Future<void> refreshDiscovery(String uid) async {
    await loadPotentialMatches(uid: uid, refresh: true);
  }

  /// Load more matches (pagination)
  Future<void> loadMore(String uid) async {
    if (!_hasMore.value || _isLoading.value) return;
    await loadPotentialMatches(uid: uid, refresh: false);
  }

  /// Clear discovery data
  void clear() {
    _potentialMatches.clear();
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
