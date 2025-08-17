import 'package:flutter/material.dart';
import 'package:pickle/views/auth/signup_screen.dart'; // Will create this file next
import 'package:pickle/views/auth/login_screen.dart'; // Will create this file next

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
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFECF67), // Updated background color
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Pickle',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Updated text color
                        ),
                      ),
                      SizedBox(height: 10),
                      Hero(
                        tag: 'logo',
                        child: Center(
                          child: Image.asset(
                            'assets/logo/logo_zoomed.png', // Assuming logo is suitable for new background
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '\"Because sometimes love comes in unexpected flavors\"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black, // Updated text color
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildAnimatedButton(
                          'Create Account',
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()),
                          ),
                          isPrimary: true,
                        ),
                        SizedBox(height: 15),
                        _buildAnimatedButton(
                          'Sign In',
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          ),
                          isPrimary: false,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black, // Updated text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary ? Color(0xFFE74C3C) : Colors.transparent, // Deep green for primary
                foregroundColor: isPrimary ? Colors.white : Colors.black, // White text for primary, black for secondary
                elevation: isPrimary ? 8 : 0,
                side: isPrimary ? null : BorderSide(color: Colors.black, width: 2), // Updated border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.5),
                ),
                shadowColor: Colors.black26,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  // Color is inherited from foregroundColor
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
