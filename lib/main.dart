import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // This import is not used, consider removing if not needed elsewhere.
// import 'dart:async'; // No longer needed here
// import 'dart:math' as math; // No longer needed here

import 'package:pickle/views/auth/splash_screen.dart'; // Adjusted import
import 'package:pickle/models/user.dart'; // For User model
import 'package:pickle/viewmodels/auth_viewmodel.dart'; // For AuthViewModel

void main() {
  runApp(PickleApp());
}

class PickleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickle Dating App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFd49b2a, {
          50: Color(0xFFFBF3E0),
          100: Color(0xFFF6E1B5),
          200: Color(0xFFEFCF85),
          300: Color(0xFFE7B957),
          400: Color(0xFFDEA32E),
          500: Color(0xFFD49B2A), // main color - deeper gold
          600: Color(0xFFC28925),
          700: Color(0xFFAD761E),
          800: Color(0xFF996118),
          900: Color(0xFF7A4310), // darkest - rich burnt orange/brown
        }),

        fontFamily: 'SF Pro Display',
      ),
      home: SplashScreen(), // SplashScreen is now imported
    );
  }
}

// Models - To be moved to models/
// class User defined in models/user.dart

// View Models - To be moved to viewmodels/
// class AuthViewModel defined in viewmodels/auth_viewmodel.dart

// Screens have been moved to their respective files in views/auth/
