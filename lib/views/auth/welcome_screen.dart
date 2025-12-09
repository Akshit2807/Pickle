import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // 👈 IMPORT LOTTIE
import 'package:pickle/views/auth/signup_screen.dart';
import 'package:pickle/views/auth/login_screen.dart';

// Define the primary color (dark pink/purple) for consistency

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // 1. Top Section - Lottie Animation
              // We use a flexible Spacer, then the Lottie, then another Spacer,
              // to perfectly center the Lottie file horizontally and vertically
              // within the top black area.
              Spacer(flex: 10),

              //REPLACED THE ICON WITH LOTTIE.ASSET
              Lottie.asset(
                'assets/lotties/welcome.json', //  file path
                width: 600, // Adjust size as needed for your animation
                height: 325,
                fit: BoxFit.contain,
                repeat: true, // Typically, welcome animations loop
              ),

              Spacer(flex: 10), // Ensures the Lottie takes up vertical space
              // 2. Bottom Content Section (The actual text and buttons)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Inclusive, reliable, safe.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Go beyond your social circle & connect\nwith people near and far.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(
                      height: 50,
                    ), // Increased spacing above the button for better look

                    _buildAnimatedButton(
                      'Next',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      ),
                      isPrimary: true,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Already have an account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 30), // Retain padding from the bottom edge
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    String text,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27.5),
              gradient: isPrimary
                  ? LinearGradient(
                      // Use the defined color for consistency
                      colors: [theme.primaryColor, theme.primaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.5),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}
