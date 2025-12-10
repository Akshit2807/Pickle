import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pickle/config/api_config.dart';
import 'package:pickle/models/api_response.dart';
import 'package:pickle/models/user_profile.dart';
import 'package:pickle/models/discovery.dart';
import 'package:pickle/models/swipe.dart';
import 'package:pickle/models/match.dart';
import 'package:pickle/models/message.dart';
import 'package:pickle/models/safety.dart';

/// Centralized API Service for Pickle Backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiConfig.getBaseUrl();

  // HTTP Client with timeout
  http.Client get _client => http.Client();

  /// Generic GET request handler
  Future<ApiResponse<T>> _get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(
        error: 'network_error',
        message: 'No internet connection',
      );
    } on TimeoutException {
      return ApiResponse.error(error: 'timeout', message: 'Request timed out');
    } catch (e) {
      return ApiResponse.error(error: 'unknown_error', message: e.toString());
    }
  }

  /// Generic POST request handler
  Future<ApiResponse<T>> _post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(
        error: 'network_error',
        message: 'No internet connection',
      );
    } on TimeoutException {
      return ApiResponse.error(error: 'timeout', message: 'Request timed out');
    } catch (e) {
      return ApiResponse.error(error: 'unknown_error', message: e.toString());
    }
  }

  /// Generic PUT request handler
  Future<ApiResponse<T>> _put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(
        error: 'network_error',
        message: 'No internet connection',
      );
    } on TimeoutException {
      return ApiResponse.error(error: 'timeout', message: 'Request timed out');
    } catch (e) {
      return ApiResponse.error(error: 'unknown_error', message: e.toString());
    }
  }

  /// Generic DELETE request handler
  Future<ApiResponse<T>> _delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await _client
          .delete(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(
        error: 'network_error',
        message: 'No internet connection',
      );
    } on TimeoutException {
      return ApiResponse.error(error: 'timeout', message: 'Request timed out');
    } catch (e) {
      return ApiResponse.error(error: 'unknown_error', message: e.toString());
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    Map<String, dynamic> jsonData = {};

    try {
      if (response.body.isNotEmpty) {
        jsonData = jsonDecode(response.body);
      }
    } catch (e) {
      return ApiResponse.error(
        error: 'parse_error',
        message: 'Failed to parse response',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      // Success
      T? data;
      if (fromJson != null && jsonData.isNotEmpty) {
        try {
          data = fromJson(jsonData);
        } catch (e) {
          return ApiResponse.error(
            error: 'parse_error',
            message: 'Failed to parse response data: $e',
            statusCode: statusCode,
            rawResponse: jsonData,
          );
        }
      }

      return ApiResponse.success(
        data: data,
        message: jsonData['message'],
        statusCode: statusCode,
        rawResponse: jsonData,
      );
    } else {
      // Error
      return ApiResponse.error(
        error: jsonData['error'] ?? 'api_error',
        message: jsonData['message'] ?? 'An error occurred',
        statusCode: statusCode,
        rawResponse: jsonData,
      );
    }
  }

  // ==================== PROFILE ENDPOINTS ====================

  /// Create user profile
  Future<ApiResponse<UserProfile>> createProfile({
    required String uid,
    required String name,
    required String email,
    required String birthdate,
    required String gender,
    required double latitude,
    required double longitude,
  }) async {
    return await _post<UserProfile>(
      ApiConfig.profile,
      body: {
        'uid': uid,
        'name': name,
        'email': email,
        'birthdate': birthdate,
        'gender': gender,
        'latitude': latitude,
        'longitude': longitude,
      },
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  /// Get own profile
  Future<ApiResponse<UserProfile>> getOwnProfile(String uid) async {
    return await _get<UserProfile>(
      ApiConfig.profile,
      queryParams: {'uid': uid},
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  /// Get another user's profile
  Future<ApiResponse<UserProfile>> getUserProfile({
    required String userId,
    required String currentUid,
  }) async {
    return await _get<UserProfile>(
      ApiConfig.profileById(userId),
      queryParams: {'uid': currentUid},
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  /// Update profile
  Future<ApiResponse<UserProfile>> updateProfile({
    required String uid,
    String? name,
    String? email,
    double? latitude,
    double? longitude,
    String? bio,
    List<String>? interests,
  }) async {
    final body = <String, dynamic>{'uid': uid};

    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (bio != null) body['bio'] = bio;
    if (interests != null) body['interests'] = interests;

    return await _put<UserProfile>(
      ApiConfig.profile,
      body: body,
      fromJson: (json) => UserProfile.fromJson(json),
    );
  }

  /// Deactivate profile
  Future<ApiResponse<Map<String, dynamic>>> deactivateProfile(
    String uid,
  ) async {
    return await _delete<Map<String, dynamic>>(
      ApiConfig.profile,
      body: {'uid': uid},
      fromJson: (json) => json,
    );
  }

  // ==================== DISCOVERY ENDPOINTS ====================

  /// Get potential matches
  Future<ApiResponse<PaginatedResponse<DiscoveryUser>>> discover({
    required String uid,
    int? limit,
    int? distanceKm,
    int? minAge,
    int? maxAge,
    List<String>? genderPreference,
    int? page,
  }) async {
    final params = DiscoveryParams(
      uid: uid,
      limit: limit,
      distanceKm: distanceKm,
      minAge: minAge,
      maxAge: maxAge,
      genderPreference: genderPreference,
      page: page,
    );

    final response = await _post<Map<String, dynamic>>(
      ApiConfig.discover,
      body: params.toJson(),
      fromJson: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!;
        final users = (data['data'] as List)
            .map((u) => DiscoveryUser.fromJson(u))
            .toList();
        final pagination = PaginationMeta.fromJson(data['pagination']);

        return ApiResponse.success(
          data: PaginatedResponse(data: users, pagination: pagination),
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'parse_error',
          message: 'Failed to parse discovery response: $e',
        );
      }
    }

    return ApiResponse.error(
      error: response.error ?? 'unknown_error',
      message: response.message ?? 'Failed to fetch matches',
      statusCode: response.statusCode,
    );
  }

  // ==================== SWIPE ENDPOINTS ====================

  /// Swipe on a user
  Future<ApiResponse<SwipeAction>> swipe({
    required String uid,
    required String swipedId,
    required String action, // "like" or "pass"
  }) async {
    return await _post<SwipeAction>(
      ApiConfig.swipe,
      body: {'uid': uid, 'swiped_id': swipedId, 'action': action},
      fromJson: (json) => SwipeAction.fromJson(json),
    );
  }

  /// Get swipe history
  Future<ApiResponse<PaginatedResponse<SwipeHistoryItem>>> getSwipeHistory({
    required String uid,
    int? limit,
    int? page,
    String? actionFilter, // "like", "pass", or "all"
  }) async {
    final body = <String, dynamic>{'uid': uid};

    if (limit != null) body['limit'] = limit;
    if (page != null) body['page'] = page;
    if (actionFilter != null) body['action_filter'] = actionFilter;

    final response = await _post<Map<String, dynamic>>(
      ApiConfig.swipeHistory,
      body: body,
      fromJson: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!;
        final swipes = (data['data'] as List)
            .map((s) => SwipeHistoryItem.fromJson(s))
            .toList();
        final pagination = PaginationMeta.fromJson(data['pagination']);

        return ApiResponse.success(
          data: PaginatedResponse(data: swipes, pagination: pagination),
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'parse_error',
          message: 'Failed to parse swipe history: $e',
        );
      }
    }

    return ApiResponse.error(
      error: response.error ?? 'unknown_error',
      message: response.message ?? 'Failed to fetch swipe history',
      statusCode: response.statusCode,
    );
  }

  // ==================== MATCH ENDPOINTS ====================

  /// Get all matches
  Future<ApiResponse<PaginatedResponse<Match>>> getMatches({
    required String uid,
    int? limit,
    int? page,
    String? sortBy, // "recent" or "alphabetical"
  }) async {
    final body = <String, dynamic>{'uid': uid};

    if (limit != null) body['limit'] = limit;
    if (page != null) body['page'] = page;
    if (sortBy != null) body['sort_by'] = sortBy;

    final response = await _post<Map<String, dynamic>>(
      ApiConfig.matches,
      body: body,
      fromJson: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!;
        final matches = (data['data'] as List)
            .map((m) => Match.fromJson(m))
            .toList();
        final pagination = PaginationMeta.fromJson(data['pagination']);

        return ApiResponse.success(
          data: PaginatedResponse(data: matches, pagination: pagination),
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'parse_error',
          message: 'Failed to parse matches: $e',
        );
      }
    }

    return ApiResponse.error(
      error: response.error ?? 'unknown_error',
      message: response.message ?? 'Failed to fetch matches',
      statusCode: response.statusCode,
    );
  }

  /// Get specific match
  Future<ApiResponse<Match>> getMatch({
    required String matchId,
    required String uid,
  }) async {
    return await _post<Match>(
      ApiConfig.matchById(matchId),
      body: {'uid': uid},
      fromJson: (json) => Match.fromJson(json),
    );
  }

  /// Unmatch a user
  Future<ApiResponse<Map<String, dynamic>>> unmatch({
    required String matchId,
    required String uid,
  }) async {
    return await _delete<Map<String, dynamic>>(
      ApiConfig.matchById(matchId),
      body: {'uid': uid},
      fromJson: (json) => json,
    );
  }

  // ==================== MESSAGE ENDPOINTS ====================

  /// Get messages in a match
  Future<ApiResponse<PaginatedResponse<Message>>> getMessages({
    required String matchId,
    required String uid,
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, String>{'uid': uid};

    if (limit != null) queryParams['limit'] = limit.toString();
    if (page != null) queryParams['page'] = page.toString();

    final response = await _get<Map<String, dynamic>>(
      ApiConfig.matchMessages(matchId),
      queryParams: queryParams,
      fromJson: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!;
        final messages = (data['data'] as List)
            .map((m) => Message.fromJson(m))
            .toList();
        final pagination = PaginationMeta.fromJson(data['pagination']);

        return ApiResponse.success(
          data: PaginatedResponse(data: messages, pagination: pagination),
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'parse_error',
          message: 'Failed to parse messages: $e',
        );
      }
    }

    return ApiResponse.error(
      error: response.error ?? 'unknown_error',
      message: response.message ?? 'Failed to fetch messages',
      statusCode: response.statusCode,
    );
  }

  /// Send a message
  Future<ApiResponse<Message>> sendMessage({
    required String matchId,
    required String uid,
    required String message,
  }) async {
    return await _post<Message>(
      ApiConfig.matchMessages(matchId),
      body: {'uid': uid, 'message': message},
      fromJson: (json) => Message.fromJson(json),
    );
  }

  /// Mark messages as read
  Future<ApiResponse<Map<String, dynamic>>> markMessagesAsRead({
    required String matchId,
    required String uid,
  }) async {
    return await _put<Map<String, dynamic>>(
      ApiConfig.markMessagesRead(matchId),
      body: {'uid': uid},
      fromJson: (json) => json,
    );
  }

  // ==================== SAFETY ENDPOINTS ====================

  /// Block a user
  Future<ApiResponse<Block>> blockUser({
    required String uid,
    required String blockedId,
    String? reason,
  }) async {
    final body = <String, dynamic>{'uid': uid, 'blocked_id': blockedId};

    if (reason != null) body['reason'] = reason;

    return await _post<Block>(
      ApiConfig.block,
      body: body,
      fromJson: (json) => Block.fromJson(json),
    );
  }

  /// Unblock a user
  Future<ApiResponse<Map<String, dynamic>>> unblockUser({
    required String blockId,
    required String uid,
  }) async {
    return await _delete<Map<String, dynamic>>(
      ApiConfig.unblock(blockId),
      body: {'uid': uid},
      fromJson: (json) => json,
    );
  }

  /// Get blocked users
  Future<ApiResponse<PaginatedResponse<Block>>> getBlockedUsers({
    required String uid,
    int? limit,
    int? page,
  }) async {
    final body = <String, dynamic>{'uid': uid};

    if (limit != null) body['limit'] = limit;
    if (page != null) body['page'] = page;

    final response = await _post<Map<String, dynamic>>(
      ApiConfig.blocked,
      body: body,
      fromJson: (json) => json,
    );

    if (response.isSuccess && response.data != null) {
      try {
        final data = response.data!;
        final blocks = (data['data'] as List)
            .map((b) => Block.fromJson(b))
            .toList();
        final pagination = PaginationMeta.fromJson(data['pagination']);

        return ApiResponse.success(
          data: PaginatedResponse(data: blocks, pagination: pagination),
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse.error(
          error: 'parse_error',
          message: 'Failed to parse blocked users: $e',
        );
      }
    }

    return ApiResponse.error(
      error: response.error ?? 'unknown_error',
      message: response.message ?? 'Failed to fetch blocked users',
      statusCode: response.statusCode,
    );
  }

  /// Report a user
  Future<ApiResponse<Report>> reportUser({
    required String uid,
    required String reportedId,
    required String reason,
    String? details,
  }) async {
    final body = <String, dynamic>{
      'uid': uid,
      'reported_id': reportedId,
      'reason': reason,
    };

    if (details != null) body['details'] = details;

    return await _post<Report>(
      ApiConfig.report,
      body: body,
      fromJson: (json) => Report.fromJson(json),
    );
  }

  // ==================== SYSTEM ENDPOINTS ====================

  /// Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    return await _get<Map<String, dynamic>>(
      ApiConfig.health,
      fromJson: (json) => json,
    );
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}
