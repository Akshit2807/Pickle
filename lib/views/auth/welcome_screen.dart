import 'package:flutter/material.dart';
import 'package:pickle/views/auth/signup_screen.dart';
import 'package:pickle/views/auth/login_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          // Use a single Column that takes all available space
          child: Column( 
            children: [
              // 1. Top Section (Black background/Blurred image placeholder)
              // Use a Container with a fixed height or a flexible widget (like below)
              // to define the top space, and let the bottom content flow naturally.
              // We'll use a Spacer to fill the space above the heart.
              
              // 2. Bottom Content Section (The actual text and buttons)
              Expanded( // Make the content section expanded to fill the remainder
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    // Aligns content to the bottom of the Expanded space
                    mainAxisAlignment: MainAxisAlignment.end, 
                    children: [
                      // Use a Spacer to dynamically push the content down
                      Spacer(flex: 20), 
                      
                      Icon(
                        Icons.favorite,
                        color: Color(0xFF660033), // Used the darkest pink from your gradient for the heart
                        size: 60,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Inclusive, reliable, safe.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Go beyond your social circle & connect\nwith people near and far.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      
                      // Add a smaller Spacer to control the gap above the button
                      Spacer(flex: 3), 
                      
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
                          color: Colors.grey,
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 30), // Retain padding from the bottom edge
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The _buildAnimatedButton method remains mostly the same, ensuring the gradient is correct.
  Widget _buildAnimatedButton(String text, VoidCallback onPressed,
      {required bool isPrimary}) {
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
                      // Pink gradient colors from the image
                      colors: [Color(0xFF660033), Color(0xFF660033)], 
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, 
                foregroundColor: Colors.white,
                elevation: 0, 
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.5),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}