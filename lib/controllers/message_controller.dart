import 'package:get/get.dart';
import 'package:pickle/models/message.dart';
import 'package:pickle/services/api_service.dart';
import 'package:pickle/controllers/match_controller.dart';

/// Controller for managing messages
class MessageController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable properties
  final RxList<Message> _messages = <Message>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _error = ''.obs;
  final RxString _currentMatchId = ''.obs;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  bool get hasMore => _hasMore.value;
  String get error => _error.value;

  /// Load messages for a match
  Future<void> loadMessages({
    required String matchId,
    required String uid,
    bool refresh = false,
  }) async {
    if (_isLoading.value) return;

    try {
      if (refresh) {
        _currentPage.value = 1;
        _messages.clear();
        _hasMore.value = true;
        _currentMatchId.value = matchId;
      }

      _isLoading.value = true;
      _error.value = '';

      final response = await _apiService.getMessages(
        matchId: matchId,
        uid: uid,
        limit: 50,
        page: _currentPage.value,
      );

      if (response.isSuccess && response.data != null) {
        final paginatedData = response.data!;
        
        if (refresh) {
          _messages.value = paginatedData.data;
        } else {
          _messages.addAll(paginatedData.data);
        }

        // Check if there are more pages
        _hasMore.value = 
            _currentPage.value < paginatedData.pagination.totalPages;
        
        if (_hasMore.value) {
          _currentPage.value++;
        }

        // Mark messages as read
        await markAsRead(matchId: matchId, uid: uid);
      } else {
        _error.value = response.message ?? 'Failed to load messages';
        
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

  /// Send a message
  Future<bool> sendMessage({
    required String matchId,
    required String uid,
    required String message,
  }) async {
    if (_isSending.value || message.trim().isEmpty) return false;

    try {
      _isSending.value = true;
      _error.value = '';

      final response = await _apiService.sendMessage(
        matchId: matchId,
        uid: uid,
        message: message.trim(),
      );

      if (response.isSuccess && response.data != null) {
        // Add message to the list
        _messages.insert(0, response.data!);
        
        _isSending.value = false;
        return true;
      } else {
        _error.value = response.message ?? 'Failed to send message';
        _isSending.value = false;
        
        Get.snackbar(
          'Error',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return false;
      }
    } catch (e) {
      _error.value = e.toString();
      _isSending.value = false;
      
      Get.snackbar(
        'Error',
        _error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead({
    required String matchId,
    required String uid,
  }) async {
    try {
      final response = await _apiService.markMessagesAsRead(
        matchId: matchId,
        uid: uid,
      );

      if (response.isSuccess) {
        // Update unread count in match controller
        try {
          final matchController = Get.find<MatchController>();
          matchController.updateUnreadCount(matchId, 0);
        } catch (e) {
          // Match controller not found, ignore
        }

        // Update local messages to mark as read
        for (int i = 0; i < _messages.length; i++) {
          if (!_messages[i].isRead) {
            _messages[i] = _messages[i].copyWith(isRead: true);
          }
        }
      }
    } catch (e) {
      // Silent fail for mark as read
    }
  }

  /// Add a new message (for real-time updates)
  void addMessage(Message message) {
    _messages.insert(0, message);
  }

  /// Refresh messages
  Future<void> refreshMessages({
    required String matchId,
    required String uid,
  }) async {
    await loadMessages(matchId: matchId, uid: uid, refresh: true);
  }

  /// Load more messages (pagination)
  Future<void> loadMore({
    required String matchId,
    required String uid,
  }) async {
    if (!_hasMore.value || _isLoading.value) return;
    await loadMessages(matchId: matchId, uid: uid, refresh: false);
  }

  /// Clear messages data
  void clear() {
    _messages.clear();
    _currentPage.value = 1;
    _hasMore.value = true;
    _error.value = '';
    _currentMatchId.value = '';
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
