import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGray = Color(0xFF2D2D2D);
  static const Color mediumGray = Color(0xFF6B6B6B);
  static const Color lightGray = Color(0xFFBDBDBD);
  static const Color ultraLightGray = Color(0xFFF0F0F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF404040);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: white,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.light(
          primary: black,
          secondary: mediumGray,
          surface: white,
          error: error,
          onPrimary: white,
          onSecondary: white,
          onSurface: black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: black,
            letterSpacing: -1.0,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: black,
            letterSpacing: -0.5,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: black,
            letterSpacing: -0.3,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: mediumGray,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
      );
}
