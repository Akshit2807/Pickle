import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:pickle/views/auth/splash_screen.dart';
import 'package:pickle/controllers/auth_controller.dart';
import 'package:pickle/controllers/profile_controller.dart';
import 'package:pickle/controllers/discovery_controller.dart';
import 'package:pickle/controllers/swipe_controller.dart';
import 'package:pickle/controllers/match_controller.dart';
import 'package:pickle/controllers/message_controller.dart';
import 'package:pickle/controllers/safety_controller.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize GetX controllers
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(DiscoveryController());
  Get.put(SwipeController());
  Get.put(MatchController());
  Get.put(MessageController());
  Get.put(SafetyController());

  runApp(PickleApp());
}

class PickleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // --- BRAND COLORS ---
    const Color burgundy = Color(0xFF660033);
    const Color charcoalPlum = Color(0xFF3C2A3E);
    const Color blushPink = Color(0xFFFFB6C1);
    const Color beige = Color(0xFFF5F5DC);
    const Color offWhite = Color(0xFFF7F4F6);
    const Color gold = Color(0xFFC5A46D);

    // Define the Custom Burgundy Swatch
    const MaterialColor burgundySwatch = MaterialColor(0xFF660033, {
      50: Color(0xFFFCEBEE),
      100: Color(0xFFF8CED8),
      200: Color(0xFFF2AEBF),
      300: Color(0xFFE889A3),
      400: Color(0xFFD95E82),
      500: Color(0xFF660033),
      600: Color(0xFF5A002D),
      700: Color(0xFF4B0025),
      800: Color(0xFF3D001D),
      900: Color(0xFF2A0013),
    });

    // --- LIGHT THEME ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: burgundy,
      scaffoldBackgroundColor: offWhite,
      cardColor: beige,
      hintColor: blushPink,
      highlightColor: blushPink.withValues(alpha: 0.4),
      splashColor: blushPink.withValues(alpha: 0.3),

      primarySwatch: burgundySwatch,

      appBarTheme: AppBarTheme(
        backgroundColor: burgundy,
        foregroundColor: offWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.signika(
          color: offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: gold),
      ),

      textTheme: GoogleFonts.signikaTextTheme(
        Theme.of(
          context,
        ).textTheme.apply(bodyColor: charcoalPlum, displayColor: charcoalPlum),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundy,
          foregroundColor: offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: charcoalPlum,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: beige,
        hintStyle: TextStyle(color: charcoalPlum.withValues(alpha: 0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: burgundy, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.5), width: 1),
        ),
      ),

      dividerColor: gold.withValues(alpha: 0.5),
      iconTheme: const IconThemeData(color: charcoalPlum),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: burgundy,
        contentTextStyle: TextStyle(color: offWhite),
        actionTextColor: gold,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: charcoalPlum,
        selectedItemColor: gold,
        unselectedItemColor: offWhite.withValues(alpha: 0.6),
        showUnselectedLabels: false,
      ),
    );

    // --- DARK THEME ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: burgundy, // Keep brand color for buttons/appbar
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      cardColor: charcoalPlum,
      hintColor: blushPink.withValues(alpha: 0.7),
      highlightColor: burgundySwatch[300]!.withValues(alpha: 0.4),
      splashColor: burgundySwatch[300]!.withValues(alpha: 0.3),

      colorScheme: ColorScheme.dark(
        primary: burgundy,
        onPrimary: offWhite,
        secondary: offWhite, // Changed to offWhite as requested
        onSecondary: burgundy,
        surface: charcoalPlum,
        onSurface: offWhite,
        error: Colors.redAccent,
        onError: Colors.white,
      ),

      primarySwatch: burgundySwatch,

      appBarTheme: AppBarTheme(
        backgroundColor: charcoalPlum,
        foregroundColor: offWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.signika(
          color: offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: offWhite), // Use offWhite for icons
      ),

      textTheme: GoogleFonts.signikaTextTheme(
        Theme.of(
          context,
        ).textTheme.apply(bodyColor: offWhite, displayColor: offWhite),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundy,
          foregroundColor: offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: burgundySwatch[400],
        foregroundColor: offWhite,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: charcoalPlum.withValues(alpha: 0.4),
        hintStyle: TextStyle(color: offWhite.withValues(alpha: 0.6)),
        labelStyle: TextStyle(color: burgundySwatch[100]), // Light label
        prefixIconColor: burgundySwatch[100], // Light icon
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: burgundySwatch[300]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: burgundySwatch[200]!.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),

      dividerColor: burgundySwatch[200]!.withValues(alpha: 0.3),
      iconTheme: IconThemeData(color: burgundySwatch[100]),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: charcoalPlum,
        contentTextStyle: TextStyle(color: offWhite),
        actionTextColor: burgundySwatch[100],
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: charcoalPlum,
        selectedItemColor: burgundySwatch[100],
        unselectedItemColor: offWhite.withValues(alpha: 0.5),
        showUnselectedLabels: false,
      ),
    );

    // --- RETURN APP ---
    return GetMaterialApp(
      title: 'Pickle Dating App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // auto-switch based on device setting
      home: SplashScreen(),
    );
  }
}
