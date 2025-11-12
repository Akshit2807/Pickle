import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:pickle/controllers/auth_controller.dart';
import 'package:pickle/views/auth/welcome_screen.dart';

// Dashboard Screen with CardSwiper
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CardSwiperController controller = CardSwiperController();

  // Profile data
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Amanda Lourence',
      'age': 19,
      'location': 'Jakarta',
      'bio': 'My name is Amanda, you can call me. I\'m 19 years old and live in Jakarta. Want to get acquainted with me?',
      'interests': ['Shopping', 'Music', 'Coffee', 'Books', 'Piano', 'Engineering', 'Movie', 'Travel'],
      'is_verified': true,
      'image': 'https://i.imgur.com/uR7Qx0H.jpeg',
    },
    {
      'name': 'Sarah',
      'age': 25,
      'location': 'Bandung',
      'bio': 'Love traveling and photography 📸 exploring new cafes.',
      'interests': ['Travel', 'Photography', 'Coffee', 'Food', 'Hiking'],
      'is_verified': false,
      'image': 'https://i.imgur.com/uR7Qx0H.jpeg',
    },
    {
      'name': 'Emma',
      'age': 23,
      'location': 'Surabaya',
      'bio': 'Yoga instructor & dog lover 🐕. Looking for someone to share sunsets with.',
      'interests': ['Yoga', 'Dogs', 'Hiking', 'Movies'],
      'is_verified': true,
      'image': 'https://i.imgur.com/uR7Qx0H.jpeg',
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    String action = '';
    Color bgColor = Colors.grey;

    switch (direction) {
      case CardSwiperDirection.right:
        action = 'It\'s giving connection! 💕';
        bgColor = Color(0xFF660033);
        HapticFeedback.lightImpact();
        break;
      case CardSwiperDirection.left:
        action = 'Not the vibe... ❌';
        bgColor = Colors.black;
        HapticFeedback.lightImpact();
        break;
      case CardSwiperDirection.top:
        action = 'Down bad fr fr! 🔥';
        bgColor = Color(0xFF660000);
        HapticFeedback.heavyImpact();
        break;
      default:
        return true;
    }

    // Hide previous snackbar instantly before showing new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(action, style: TextStyle(color: Colors.white)),
        backgroundColor: bgColor,
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.fixed,
      ),
    );

    // TODO: Call API to save the action
    debugPrint('Action: $action on profile: ${_profiles[previousIndex]['name']}');

    return true;
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass (X) Button
          _buildActionButton(
            icon: Icons.close,
            size: 65,
            iconSize: 32,
            backgroundColor: Colors.white,
            iconColor: Color(0xFFFF5270),
            onTap: () => controller.swipe(CardSwiperDirection.left),
          ),
          SizedBox(width: 24),
          // Super Like (Fire) Button
          _buildActionButton(
            icon: Icons.local_fire_department,
            size: 75,
            iconSize: 40,
            gradient: LinearGradient(
              colors: [Color(0xFFFF5270), Color(0xFFFF3D54)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            iconColor: Colors.white,
            onTap: () => controller.swipe(CardSwiperDirection.top),
            elevation: 8,
          ),
          SizedBox(width: 24),
          // Like (Heart) Button
          _buildActionButton(
            icon: Icons.favorite,
            size: 65,
            iconSize: 32,
            backgroundColor: Colors.white,
            iconColor: Color(0xFFFF5270),
            onTap: () => controller.swipe(CardSwiperDirection.right),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required double size,
    required double iconSize,
    Color? backgroundColor,
    Gradient? gradient,
    required Color iconColor,
    required VoidCallback onTap,
    double elevation = 4,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: gradient == null ? backgroundColor : null,
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Profile Image
          Positioned.fill(
            child: Image.network(
              profile['image'],
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                );
              },
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Logout Button (top right) - Temporary
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                final authController = Get.find<AuthController>();
                await authController.signOut();
                Get.offAll(() => WelcomeScreen());
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Profile Info (bottom)
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Verification Badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (profile['is_verified'])
                      Icon(
                        Icons.verified,
                        color: Color(0xFF1DA1F2),
                        size: 28,
                      ),
                  ],
                ),
                SizedBox(height: 12),

                // Bio Text
                Text(
                  profile['bio'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Interest Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (profile['interests'] as List<String>).map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Card Swiper
            Positioned.fill(
              child: CardSwiper(
                controller: controller,
                cardsCount: _profiles.length,
                onSwipe: _onSwipe,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(0, 10),
                padding: const EdgeInsets.all(0),
                cardBuilder: (
                  context,
                  index,
                  horizontalThresholdPercentage,
                  verticalThresholdPercentage,
                ) {
                  return _buildProfileCard(_profiles[index]);
                },
                isLoop: true,
                allowedSwipeDirection: AllowedSwipeDirection.symmetric(
                  horizontal: true,
                  vertical: true,
                ),
              ),
            ),

            // Action Buttons (bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }
}
