import 'package:accenture_photobooth/core/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    // Base Theme Configuration
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: "GraphikTrial",
    primaryColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.black,

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.white,
      circularTrackColor: AppColors.white.withValues(alpha: 0.2),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      iconTheme: IconThemeData(color: AppColors.white),
      actionsIconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "GraphikTrial",
      ),
      // This ensures the automatic back button uses the foregroundColor
      toolbarTextStyle: TextStyle(color: AppColors.white),
      systemOverlayStyle: null,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.white, // Dialog background
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: "GraphikTrial",
      ),
      contentTextStyle: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: "GraphikTrial",
      ),
    ),

    // Icon Themes
    iconTheme: const IconThemeData(color: AppColors.white),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(iconColor: WidgetStatePropertyAll(AppColors.white)),
    ),

    // Button Themes
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.white),
        iconColor: const WidgetStatePropertyAll(AppColors.white),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.white, fontFamily: "GraphikTrial"),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        iconColor: AppColors.black,
        elevation: 0,
        foregroundColor: Color(0xFF460073),
        backgroundColor: AppColors.white,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 45,
          fontFamily: "GraphikTrial",
          color: Color(0xFF460073),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
    ),

    // Notification Theme
    snackBarTheme: const SnackBarThemeData(closeIconColor: AppColors.white),

    // Form Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        fontFamily: "GraphikTrial",
      ),
      headlineMedium: TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: "GraphikTrial",
      ),
      headlineSmall: TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: "GraphikTrial",
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.5,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: AppColors.white,
        fontFamily: "GraphikTrial",
      ),
    ),
  );
}
