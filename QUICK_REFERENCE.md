# Pickle API Quick Reference

## 🚀 Getting Started (3 Steps)

### Step 1: Configure Base URL
Edit `lib/config/api_config.dart`:

```dart
// Choose based on your testing environment:
static const String baseUrl = 'http://10.0.2.2:10000/api/v1';  // Android Emulator
// static const String baseUrl = 'http://localhost:10000/api/v1';  // iOS Simulator
// static const String baseUrl = 'http://192.168.x.x:10000/api/v1';  // Physical Device
```

### Step 2: Start Backend
```bash
python app.py
```

### Step 3: Run App
```bash
flutter run
```

---

## 📱 Controller Reference

### Get Controllers
All controllers are pre-initialized in `main.dart`:

```dart
final profileController = Get.find<ProfileController>();
final discoveryController = Get.find<DiscoveryController>();
final swipeController = Get.find<SwipeController>();
final matchController = Get.find<MatchController>();
final messageController = Get.find<MessageController>();
final safetyController = Get.find<SafetyController>();
```

---

## 🔑 Common Operations

### Profile Management

```dart
// Get current user's profile
await profileController.loadProfile(uid);
UserProfile? profile = profileController.profile;

// Update profile
await profileController.updateProfile(
  uid: uid,
  bio: 'New bio',
  interests: ['hiking', 'reading'],
);

// Get another user's profile
final response = await profileController.getUserProfile(
  userId: targetUserId,
  currentUid: currentUid,
);
```

### Discovery Feed

```dart
// Set filters
discoveryController.setDistanceKm(50);
discoveryController.setMinAge(21);
discoveryController.setMaxAge(35);
discoveryController.setGenderPreference(['female']);

// Load potential matches
await discoveryController.loadPotentialMatches(uid: uid, refresh: true);

// Access matches
List<DiscoveryUser> users = discoveryController.potentialMatches;
```

### Swipe Actions

```dart
// Swipe like
final result = await swipeController.swipeLike(uid: uid, swipedId: targetId);
if (result?.isMatch == true) {
  print('Match! ID: ${result?.matchId}');
}

// Swipe pass
await swipeController.swipePass(uid: uid, swipedId: targetId);
```

### Matches

```dart
// Load all matches
await matchController.loadMatches(uid: uid, refresh: true);

// Get unread count
int unread = matchController.unreadMatchesCount;

// Unmatch
await matchController.unmatch(matchId: matchId, uid: uid);
```

### Messaging

```dart
// Load messages
await messageController.loadMessages(matchId: matchId, uid: uid, refresh: true);

// Send message
await messageController.sendMessage(
  matchId: matchId,
  uid: uid,
  message: 'Hello!',
);
```

### Safety

```dart
// Block user
await safetyController.blockUser(uid: uid, blockedId: targetId, reason: 'spam');

// Report user
await safetyController.reportUser(
  uid: uid,
  reportedId: targetId,
  reason: ReportReason.harassment,
  details: 'Inappropriate behavior',
);

// Get blocked users
await safetyController.loadBlockedUsers(uid: uid);
```

---

## 📊 Observable Properties

### ProfileController
- `profile` - Current user's profile
- `isLoading` - Loading state
- `error` - Error message

### DiscoveryController
- `potentialMatches` - List of potential matches
- `isLoading` - Loading state
- `hasMore` - More pages available
- `distanceKm`, `minAge`, `maxAge`, `genderPreference` - Current filters

### SwipeController
- `isProcessing` - Swipe in progress
- `lastSwipe` - Last swipe action
- `isMatch` - Whether last swipe was a match

### MatchController
- `matches` - List of matches
- `isLoading` - Loading state
- `unreadMatchesCount` - Count of matches with unread messages

### MessageController
- `messages` - List of messages
- `isLoading` - Loading messages
- `isSending` - Sending message

### SafetyController
- `blockedUsers` - List of blocked users
- `isLoading` - Loading state

---

## ⚡ Quick Snippets

### Check API Health
```dart
final apiService = ApiService();
final response = await apiService.healthCheck();
print(response.data);
```

### Get Current User UID
```dart
final authController = Get.find<AuthController>();
String? uid = authController.firebaseUser?.uid;
```

### Handle API Errors
```dart
final response = await apiService.someEndpoint();
if (response.isSuccess) {
  // Success
  var data = response.data;
} else {
  // Error
  print('Error: ${response.message}');
  print('Code: ${response.error}');
}
```

### Load More (Pagination)
```dart
// Discovery
await discoveryController.loadMore(uid);

// Matches
await matchController.loadMore(uid);

// Messages
await messageController.loadMore(matchId: matchId, uid: uid);
```

---

## 🔍 Debugging

### Enable Request Logging
Add to `api_service.dart`:
```dart
print('Request: ${uri.toString()}');
print('Body: ${jsonEncode(body)}');
print('Response: ${response.body}');
```

### Check Controller State
```dart
print('Loading: ${controller.isLoading}');
print('Error: ${controller.error}');
print('Data: ${controller.someData}');
```

---

## 📋 Checklist

Before deploying:
- [ ] Update base URL in `api_config.dart`
- [ ] Test all API endpoints
- [ ] Handle error states in UI
- [ ] Add loading indicators
- [ ] Test pagination
- [ ] Verify auth flow
- [ ] Test on different platforms (iOS/Android)
- [ ] Check network error handling

---

## 🆘 Common Issues

| Issue | Solution |
|-------|----------|
| Connection refused | Check base URL for your platform |
| 401 Unauthorized | Verify UID is being passed |
| Timeout | Backend not running or network down |
| Parse error | Backend response doesn't match model |
| Controller not found | Ensure controller is initialized in main.dart |

---

## 📚 Full Documentation

- **Integration Guide**: `API_INTEGRATION.md`
- **Summary**: `INTEGRATION_SUMMARY.md`
- **Backend API Docs**: `http://YOUR_BASE_URL/docs`

---

**Last Updated**: December 10, 2025
