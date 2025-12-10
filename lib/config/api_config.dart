/// API Configuration for Pickle Backend
class ApiConfig {
  // Base URL - Update this to your deployed backend URL in production
  static const String baseUrl = 'http://0.0.0.0:10000/api/v1';
  
  // For Android Emulator, use: 'http://10.0.2.2:10000/api/v1'
  // For iOS Simulator, use: 'http://localhost:10000/api/v1'
  // For Physical Device, use your computer's local IP: 'http://192.168.x.x:10000/api/v1'
  
  static const String androidEmulatorUrl = 'http://10.0.2.2:10000/api/v1';
  static const String iosSimulatorUrl = 'http://localhost:10000/api/v1';
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Endpoints
  
  // Profile endpoints
  static const String profile = '/profile';
  static String profileById(String userId) => '/profile/$userId';
  
  // Discovery endpoints
  static const String discover = '/discover';
  
  // Swipe endpoints
  static const String swipe = '/swipe';
  static const String swipeHistory = '/swipes/history';
  
  // Match endpoints
  static const String matches = '/matches';
  static String matchById(String matchId) => '/matches/$matchId';
  static String matchMessages(String matchId) => '/matches/$matchId/messages';
  static String markMessagesRead(String matchId) => '/matches/$matchId/messages/read';
  
  // Safety endpoints
  static const String block = '/block';
  static String unblock(String blockId) => '/block/$blockId';
  static const String blocked = '/blocked';
  static const String report = '/report';
  
  // System endpoints
  static const String docs = '/docs';
  static const String health = '/health';
  
  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Distance defaults (in kilometers)
  static const int defaultDistanceKm = 50;
  static const int maxDistanceKm = 200;
  
  // Message limits
  static const int maxMessageLength = 1000;
  
  // Helper method to get the appropriate base URL based on platform
  static String getBaseUrl() {
    // TODO: Update this to your production backend URL before deploying
    // For development, you can use the appropriate URL for your testing environment
    
    // Option 1: Use environment variable (recommended for production)
    // const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: baseUrl);
    // return backendUrl;
    
    // Option 2: Use the default baseUrl
    return baseUrl;
    
    // Note: For testing on different platforms:
    // - Android Emulator: Use androidEmulatorUrl
    // - iOS Simulator: Use iosSimulatorUrl
    // - Physical Device: Replace baseUrl with your computer's local IP
  }
}
