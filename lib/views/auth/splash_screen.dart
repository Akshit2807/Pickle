import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:pickle/widgets/animations/floating_logo.dart'; // Adjusted import
import 'package:pickle/views/auth/welcome_screen.dart'; // Will create this file next

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _backgroundRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _backgroundController.repeat();
    _logoController.forward();

    Timer(Duration(seconds: 3), () {
      if (mounted) { // Added mounted check
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => WelcomeScreen(),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFECF67), // Updated background color
        ),
        child: Stack(
          children: [
            // Animated Background Elements - kept as white with opacity for now
            AnimatedBuilder(
              animation: _backgroundRotation,
              builder: (context, child) {
                return Positioned(
                  top: -100,
                  right: -100,
                  child: Transform.rotate(
                    angle: _backgroundRotation.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _backgroundRotation,
              builder: (context, child) {
                return Positioned(
                  bottom: -50,
                  left: -50,
                  child: Transform.rotate(
                    angle: -_backgroundRotation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Floating Logos
            ...List.generate(6, (index) => FloatingHeart(delay: index * 0.5)), // Assuming FloatingHeart is designed to work with any background
            // Logo
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // SizedBox(height: 20),
                          Text(
                            'Pickle',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Updated text color
                              // Removed shadows as they might not look good with black text on this background
                            ),
                          ),
                          Center(
                            child: Image.asset( // Changed from Icon
                              'assets/logo/logo_zoomed.png',
                              width: 140,
                              height: 140,
                            ),
                          ),
                          Text(
                            'Find Your Perfect Match',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Updated text color
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
