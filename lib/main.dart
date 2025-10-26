import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:pickle/views/auth/splash_screen.dart';
import 'package:pickle/controllers/auth_controller.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize GetX controllers
  Get.put(AuthController());

  runApp(PickleApp());
}

class PickleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
        textTheme: GoogleFonts.signikaTextTheme(
          Theme.of(context).textTheme,
        ),
        fontFamily: GoogleFonts.signika().fontFamily,
      ),
      home: SplashScreen(),
    );
  }
}

