# 🚀 Production Deployment Checklist

## ⚠️ IMPORTANT: Remove All Dummy Data Before Production

This checklist ensures your Pickle app is using **real data** from the backend API, not placeholder values.

---

## ✅ Configuration Steps

### 1. Backend URL Configuration

**File**: `lib/config/api_config.dart`

**Current (Development)**:
```dart
static const String baseUrl = 'http://0.0.0.0:10000/api/v1';
```

**Update to (Production)**:
```dart
static const String baseUrl = 'https://your-production-domain.com/api/v1';
```

**Environment-based Configuration (Recommended)**:
```dart
static String getBaseUrl() {
  const backendUrl = String.fromEnvironment('BACKEND_URL', 
    defaultValue: 'https://your-production-domain.com/api/v1'
  );
  return backendUrl;
}
```

Then run with:
```bash
flutter run --dart-define=BACKEND_URL=https://your-backend.com/api/v1
```

---

### 2. GPS Location - REQUIRED ⚠️

**File**: `lib/controllers/auth_controller.dart`

**Issue**: Currently defaults to `(0.0, 0.0)` if no location provided.

**Fix Required**:
```dart
// ❌ BAD - Using dummy coordinates
latitude: 0.0,
longitude: 0.0,

// ✅ GOOD - Getting real device location
final position = await Geolocator.getCurrentPosition();
latitude: position.latitude,
longitude: position.longitude,
```

**Action Items**:
- [ ] Implement location permission request
- [ ] Get real GPS coordinates from device
- [ ] Pass coordinates to `signUp()` method
- [ ] Update location when user moves (for discovery accuracy)

**Example Implementation**:
```dart
// In your signup flow
import 'package:geolocator/geolocator.dart';

// Request permission
LocationPermission permission = await Geolocator.requestPermission();

// Get current location
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);

// Use in signup
await authController.signUp(
  user: user,
  latitude: position.latitude,  // Real GPS data
  longitude: position.longitude, // Real GPS data
);
```

---

### 3. User Data Validation

Ensure all user inputs are real and validated:

**Profile Creation Requirements**:
- ✅ Real email address (verified)
- ✅ Valid birthdate (age 18+)
- ✅ Actual GPS coordinates
- ✅ Real name (enforced by verification)
- ✅ Valid gender selection
- ✅ Real bio and interests

**Validation Example**:
```dart
// Age validation
int calculateAge(DateTime birthdate) {
  final today = DateTime.now();
  int age = today.year - birthdate.year;
  if (today.month < birthdate.month || 
      (today.month == birthdate.month && today.day < birthdate.day)) {
    age--;
  }
  return age;
}

// Enforce minimum age
if (calculateAge(user.birthDate!) < 18) {
  throw Exception('Must be 18 or older');
}
```

---

### 4. Discovery Filters - Use Real Preferences

**File**: `lib/controllers/discovery_controller.dart`

**Current**: Default values set in controller

**Update**: Use user's actual preferences from profile/settings

```dart
// ❌ BAD - Hardcoded defaults
discoveryController.setDistanceKm(50);
discoveryController.setMinAge(18);
discoveryController.setMaxAge(45);

// ✅ GOOD - User's saved preferences
final preferences = await getUserPreferences(uid);
discoveryController.setDistanceKm(preferences.maxDistance);
discoveryController.setMinAge(preferences.minAge);
discoveryController.setMaxAge(preferences.maxAge);
discoveryController.setGenderPreference(preferences.genderPreference);
```

---

### 5. Remove Debug/Test Data

**Search for and remove**:
```bash
grep -r "test" lib/ --include="*.dart"
grep -r "dummy" lib/ --include="*.dart"
grep -r "example" lib/ --include="*.dart"
```

**Common places to check**:
- [ ] No test emails (test@example.com)
- [ ] No placeholder names (John Doe, Jane Smith)
- [ ] No hardcoded IDs
- [ ] No mock responses

---

### 6. API Error Handling

Ensure proper error handling for production:

```dart
// ✅ GOOD - Comprehensive error handling
try {
  final response = await apiService.discover(uid: uid);
  
  if (response.isSuccess && response.data != null) {
    // Handle success
  } else {
    // Log error for monitoring
    logError('Discovery failed', {
      'error': response.error,
      'message': response.message,
      'statusCode': response.statusCode,
    });
    
    // Show user-friendly message
    showErrorDialog('Unable to load matches. Please try again.');
  }
} catch (e) {
  // Handle exceptions
  logException(e);
  showErrorDialog('An unexpected error occurred.');
}
```

---

### 7. Security Considerations

**Authentication**:
- ✅ Firebase UID used for all API calls
- ✅ No hardcoded credentials
- ✅ Secure token storage
- ⚠️ Consider migrating to JWT tokens for production

**Data Protection**:
```dart
// Never log sensitive data in production
if (kDebugMode) {
  print('User data: $userData');
}

// Use Flutter's foundation.dart
import 'package:flutter/foundation.dart';
if (kDebugMode) {
  // Debug logging only
}
```

---

### 8. Performance Optimization

**Caching Strategy**:
```dart
// Cache profile data locally
await SharedPreferences.getInstance().then((prefs) {
  prefs.setString('cached_profile', jsonEncode(profile.toJson()));
});

// Load from cache first, then refresh
final cachedProfile = prefs.getString('cached_profile');
if (cachedProfile != null) {
  profile = UserProfile.fromJson(jsonDecode(cachedProfile));
  // Show cached data immediately
}
// Then fetch fresh data in background
await profileController.loadProfile(uid);
```

**Image Loading**:
```dart
// Use cached network images
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: user.photos.first.url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

### 9. Analytics & Monitoring

**Track Real User Events**:
```dart
// Example with Firebase Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Track swipe events
await analytics.logEvent(
  name: 'swipe_action',
  parameters: {
    'action': 'like', // or 'pass'
    'target_user_age': targetUser.age,
    'is_match': result?.isMatch ?? false,
  },
);

// Track matches
if (result?.isMatch == true) {
  await analytics.logEvent(name: 'match_created');
}
```

---

### 10. Testing Checklist

**Before Production**:
- [ ] Test with real user accounts (not test accounts)
- [ ] Verify GPS coordinates are accurate
- [ ] Test discovery with actual location data
- [ ] Confirm swipe actions create real matches
- [ ] Verify messages send/receive correctly
- [ ] Test block/report functionality
- [ ] Ensure profile updates work
- [ ] Test on real devices (not just emulators)
- [ ] Test with slow/unstable network
- [ ] Verify error messages are user-friendly

**Load Testing**:
- [ ] Test with multiple concurrent users
- [ ] Verify pagination works with large datasets
- [ ] Check performance with many matches/messages
- [ ] Monitor API response times

---

## 🔧 Quick Fixes

### Fix 1: Real Location on Signup
```dart
// In your signup flow UI
Future<void> _handleSignup() async {
  // Get location first
  final position = await Geolocator.getCurrentPosition();
  
  // Then signup with real coordinates
  final success = await authController.signUp(
    user: user,
    latitude: position.latitude,
    longitude: position.longitude,
  );
}
```

### Fix 2: Production API URL
```dart
// lib/config/api_config.dart
static const String baseUrl = 'https://api.pickledating.com/api/v1';
```

### Fix 3: Remove Debug Prints
```bash
# Find all print statements
grep -rn "print(" lib/

# Replace with proper logging
import 'package:logger/logger.dart';
final logger = Logger();
logger.d('Debug message');
logger.w('Warning message');
logger.e('Error message');
```

---

## 📊 Data Flow Verification

### 1. Signup Flow
```
User Input → Firebase Auth → API Profile Creation → ProfileController
                                      ↓
                              Real GPS Coordinates
```

### 2. Discovery Flow
```
User Location → API Discovery Endpoint → Real Users Within Distance
                        ↓
              Filter by Age/Gender/Preferences
                        ↓
              Return Real Potential Matches
```

### 3. Swipe Flow
```
Like/Pass Action → API Swipe Endpoint → Check for Match
                                ↓
                         If Both Liked: Create Match
```

---

## ✅ Final Checklist

Before going live:
- [ ] Backend API deployed and accessible
- [ ] Production URL updated in `api_config.dart`
- [ ] Real GPS coordinates implemented
- [ ] All test/dummy data removed
- [ ] Error handling comprehensive
- [ ] Analytics tracking configured
- [ ] Security measures in place
- [ ] Performance optimized
- [ ] Tested on real devices
- [ ] User data properly validated
- [ ] Privacy policy implemented
- [ ] Terms of service accepted by users

---

## 📞 Support

If you encounter issues with real data integration:
1. Check backend API logs
2. Verify network requests in Flutter DevTools
3. Test endpoints with Postman
4. Review error messages in console
5. Check Firebase console for auth issues

---

**Last Updated**: December 10, 2025

**Status**: ⚠️ DEVELOPMENT MODE - UPDATE BEFORE PRODUCTION
