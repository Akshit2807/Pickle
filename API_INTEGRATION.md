# Pickle API Integration Guide

## Overview
This document describes the complete API integration for the Pickle dating app, following the backend API specification.

## Base URL Configuration

The backend API base URL is configured in `/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://0.0.0.0:10000/api/v1';
```

### Platform-Specific URLs

- **Android Emulator**: `http://10.0.2.2:10000/api/v1`
- **iOS Simulator**: `http://localhost:10000/api/v1`
- **Physical Device**: `http://YOUR_LOCAL_IP:10000/api/v1` (e.g., `http://192.168.1.100:10000/api/v1`)

Update the `baseUrl` in `api_config.dart` based on your testing environment.

## Architecture

### 1. Models (`/lib/models/`)

#### API Models
- **`api_response.dart`**: Generic response wrapper with success/error states
- **`user_profile.dart`**: User profile model matching backend API
- **`discovery.dart`**: Discovery/swipe feed models
- **`swipe.dart`**: Swipe action and history models
- **`match.dart`**: Match models
- **`message.dart`**: Message models
- **`safety.dart`**: Block and report models

#### Legacy Models
- **`user.dart`**: Original user model for local data and Firestore

### 2. Services (`/lib/services/`)

#### `api_service.dart`
Centralized API service handling all backend endpoints:

**Profile Endpoints:**
- `createProfile()` - Create user profile
- `getOwnProfile()` - Get current user's profile
- `getUserProfile()` - Get another user's profile
- `updateProfile()` - Update profile information
- `deactivateProfile()` - Soft-delete profile

**Discovery Endpoints:**
- `discover()` - Get potential matches with filters

**Swipe Endpoints:**
- `swipe()` - Perform swipe action (like/pass)
- `getSwipeHistory()` - Get user's swipe history

**Match Endpoints:**
- `getMatches()` - Get all matches
- `getMatch()` - Get specific match details
- `unmatch()` - Unmatch with a user

**Message Endpoints:**
- `getMessages()` - Get messages in a match
- `sendMessage()` - Send a message
- `markMessagesAsRead()` - Mark messages as read

**Safety Endpoints:**
- `blockUser()` - Block a user
- `unblockUser()` - Unblock a user
- `getBlockedUsers()` - Get list of blocked users
- `reportUser()` - Report a user

**System Endpoints:**
- `healthCheck()` - Check API health

### 3. Controllers (`/lib/controllers/`)

#### `auth_controller.dart`
- Handles Firebase authentication
- Creates backend API profile after signup
- Loads profile on sign-in
- Clears all controller data on sign-out

#### `profile_controller.dart`
- Manages user profile data
- CRUD operations for profiles
- Profile state management

#### `discovery_controller.dart`
- Manages discovery/swipe feed
- Filter management (distance, age, gender preference)
- Pagination support

#### `swipe_controller.dart`
- Handles swipe actions (like/pass)
- Match notifications
- Swipe history

#### `match_controller.dart`
- Manages user matches
- Unread message tracking
- Match sorting and pagination

#### `message_controller.dart`
- Manages messages within matches
- Send/receive messages
- Mark as read functionality

#### `safety_controller.dart`
- Block/unblock users
- Report users
- Blocked users list management

## Usage Examples

### 1. User Signup with API Integration

```dart
final authController = Get.find<AuthController>();
final success = await authController.signUp(
  user: user,
  latitude: currentLatitude,
  longitude: currentLongitude,
);
```

The signup process:
1. Creates Firebase auth user
2. Saves to Firestore (backup)
3. Creates profile on backend API
4. Loads profile into ProfileController

### 2. Discovery/Swipe Feed

```dart
final discoveryController = Get.find<DiscoveryController>();

// Set filters
discoveryController.setDistanceKm(50);
discoveryController.setMinAge(21);
discoveryController.setMaxAge(35);
discoveryController.setGenderPreference(['female']);

// Load potential matches
await discoveryController.loadPotentialMatches(
  uid: currentUserUid,
  refresh: true,
);

// Access matches
List<DiscoveryUser> matches = discoveryController.potentialMatches;
```

### 3. Swipe Actions

```dart
final swipeController = Get.find<SwipeController>();

// Swipe like
final result = await swipeController.swipeLike(
  uid: currentUserUid,
  swipedId: targetUserId,
);

// Check if it's a match
if (result?.isMatch == true) {
  print('It\'s a match! Match ID: ${result?.matchId}');
}

// Swipe pass
await swipeController.swipePass(
  uid: currentUserUid,
  swipedId: targetUserId,
);
```

### 4. Matches

```dart
final matchController = Get.find<MatchController>();

// Load matches
await matchController.loadMatches(
  uid: currentUserUid,
  refresh: true,
);

// Get unread count
int unreadCount = matchController.unreadMatchesCount;

// Unmatch
await matchController.unmatch(
  matchId: matchId,
  uid: currentUserUid,
);
```

### 5. Messaging

```dart
final messageController = Get.find<MessageController>();

// Load messages
await messageController.loadMessages(
  matchId: matchId,
  uid: currentUserUid,
  refresh: true,
);

// Send message
await messageController.sendMessage(
  matchId: matchId,
  uid: currentUserUid,
  message: 'Hello!',
);

// Messages are automatically marked as read when loaded
```

### 6. Safety Features

```dart
final safetyController = Get.find<SafetyController>();

// Block user
await safetyController.blockUser(
  uid: currentUserUid,
  blockedId: targetUserId,
  reason: 'spam',
);

// Report user
await safetyController.reportUser(
  uid: currentUserUid,
  reportedId: targetUserId,
  reason: ReportReason.harassment,
  details: 'User sent inappropriate messages',
);

// Get blocked users
await safetyController.loadBlockedUsers(uid: currentUserUid);
```

### 7. Profile Updates

```dart
final profileController = Get.find<ProfileController>();

// Update profile
await profileController.updateProfile(
  uid: currentUserUid,
  bio: 'Updated bio text',
  interests: ['hiking', 'photography', 'travel'],
  latitude: newLatitude,
  longitude: newLongitude,
);

// Get another user's profile
final response = await profileController.getUserProfile(
  userId: targetUserId,
  currentUid: currentUserUid,
);
```

## Error Handling

All API calls return `ApiResponse<T>` which contains:
- `success`: Boolean indicating success/failure
- `data`: Response data (type T)
- `error`: Error code
- `message`: Human-readable error message
- `statusCode`: HTTP status code

Example error handling:

```dart
final response = await apiService.getOwnProfile(uid);

if (response.isSuccess && response.data != null) {
  // Success
  final profile = response.data!;
} else {
  // Error
  print('Error: ${response.message}');
  print('Error code: ${response.error}');
  print('Status code: ${response.statusCode}');
}
```

## Authentication

All API endpoints require Firebase UID authentication. The UID is automatically included in requests by the controllers.

## Pagination

Endpoints supporting pagination use:
- `limit`: Items per page
- `page`: Page number (1-indexed)
- Response includes `PaginationMeta` with total counts and pages

## Testing the Integration

### 1. Start the Backend Server

Ensure the backend API is running:
```bash
python app.py  # or your backend start command
```

### 2. Update Base URL

In `/lib/config/api_config.dart`, set the correct base URL for your testing environment.

### 3. Run the App

```bash
flutter pub get
flutter run
```

### 4. Test Health Endpoint

You can verify the API connection:

```dart
final apiService = ApiService();
final response = await apiService.healthCheck();
print('API Status: ${response.data}');
```

## Common Issues

### 1. Connection Refused

**Problem**: Cannot connect to backend API

**Solutions**:
- Verify backend server is running
- Check base URL in `api_config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use your computer's local IP address
- Ensure no firewall is blocking the connection

### 2. Timeout Errors

**Problem**: Requests timeout

**Solutions**:
- Check network connectivity
- Increase timeout in `api_config.dart`
- Verify backend is responding (test with curl/Postman)

### 3. Parse Errors

**Problem**: Failed to parse response

**Solutions**:
- Verify backend API matches the documentation
- Check model `fromJson` methods
- Enable debug logging to see raw response

## Future Enhancements

### 1. Real-time Messaging
Consider integrating WebSockets or Firebase Cloud Messaging for real-time message delivery.

### 2. Image Upload
Implement photo upload functionality for profile pictures and verification images.

### 3. Push Notifications
Add push notifications for matches, messages, and other events.

### 4. Caching
Implement local caching for offline support and improved performance.

### 5. Token-Based Auth
Consider migrating from UID-based auth to token-based (JWT) authentication for enhanced security.

## Dependencies

Required packages (already added to `pubspec.yaml`):
- `http: ^1.1.0` - HTTP client
- `get: ^4.6.6` - State management
- `firebase_core` - Firebase initialization
- `firebase_auth` - Firebase authentication

## API Documentation

Full API documentation is available at:
- Swagger UI: `http://YOUR_BASE_URL/docs`
- Health Check: `http://YOUR_BASE_URL/health`

## Support

For API-related issues:
1. Check backend logs
2. Verify request/response format
3. Test endpoints with Postman/curl
4. Review error codes and messages

For integration issues:
1. Check controller initialization
2. Verify UID is being passed correctly
3. Review error handling in controllers
4. Enable debug logging in ApiService
