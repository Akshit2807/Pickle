import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pickle/views/auth/splash_screen.dart';
import 'package:pickle/models/user.dart';
import 'package:pickle/viewmodels/auth_viewmodel.dart';

void main() {
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

    // --- LIGHT THEME ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: burgundy,
      scaffoldBackgroundColor: offWhite,
      cardColor: beige,
      hintColor: blushPink,
      highlightColor: blushPink.withValues(alpha: 0.4),
      splashColor: blushPink.withValues(alpha: 0.3),

      primarySwatch: MaterialColor(0xFF660033, {
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
      }),

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
        Theme.of(context).textTheme.apply(
              bodyColor: charcoalPlum,
              displayColor: charcoalPlum,
            ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundy,
          foregroundColor: offWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
      primaryColor: gold,
      scaffoldBackgroundColor: const Color(0xFF1E1A1D),
      cardColor: charcoalPlum,
      hintColor: blushPink.withValues(alpha: 0.7),
      highlightColor: gold.withValues(alpha: 0.4),
      splashColor: gold.withValues(alpha: 0.3),

      appBarTheme: AppBarTheme(
        backgroundColor: charcoalPlum,
        foregroundColor: offWhite,
        titleTextStyle: GoogleFonts.signika(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),

      textTheme: GoogleFonts.signikaTextTheme(
        Theme.of(context).textTheme.apply(
              bodyColor: offWhite,
              displayColor: offWhite,
            ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: charcoalPlum,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: charcoalPlum,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: charcoalPlum.withValues(alpha: 0.4),
        hintStyle: TextStyle(color: offWhite.withValues(alpha: 0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold.withValues(alpha: 0.4), width: 1),
        ),
      ),

      dividerColor: gold.withValues(alpha: 0.3),
      iconTheme: const IconThemeData(color: gold),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: charcoalPlum,
        contentTextStyle: TextStyle(color: offWhite),
        actionTextColor: gold,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: charcoalPlum,
        selectedItemColor: gold,
        unselectedItemColor: offWhite.withValues(alpha: 0.5),
        showUnselectedLabels: false,
      ),
    );

    // --- RETURN APP ---
    return MaterialApp(
      title: 'Pickle Dating App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, // auto-switch based on device setting
      home: SplashScreen(),
    );
  }
}
