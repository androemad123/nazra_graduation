import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'font_manager.dart';

class ThemeManager {
  static ThemeData getLightTheme(String languageCode) {
    final fontFamily = FontConstants.getFontFamily(languageCode);

    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.white,
        foregroundColor: ColorManager.black,
        centerTitle: true,
      ),
      brightness: Brightness.light,
      fontFamily: fontFamily,
      primaryColor: ColorManager.brown,
      scaffoldBackgroundColor: ColorManager.white,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily),
        displayMedium: TextStyle(fontFamily: fontFamily),
        displaySmall: TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
        headlineSmall: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(
          color: ColorManager.black,
          fontWeight: FontWeightManager.semiBold,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(fontFamily: fontFamily),
        titleSmall: TextStyle(fontFamily: fontFamily),
        bodyLarge: const TextStyle(color: ColorManager.lightGray),
        bodyMedium: const TextStyle(color: ColorManager.gray),
        bodySmall: const TextStyle(color: ColorManager.gray),
        labelLarge: TextStyle(fontFamily: fontFamily),
        labelMedium: TextStyle(fontFamily: fontFamily),
        labelSmall: TextStyle(fontFamily: fontFamily),
      ),
      colorScheme: const ColorScheme.light(
        primary: ColorManager.brown,
        secondary: ColorManager.lightBrown,
        surface: ColorManager.beige,
        onPrimary: ColorManager.black,
        onSecondary: ColorManager.white,
        onSurface: ColorManager.gray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.brown,
          foregroundColor: ColorManager.white,
          disabledBackgroundColor: ColorManager.lightGray,
          disabledForegroundColor: ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorManager.black,
          textStyle: TextStyle(
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
      ),
      shadowColor: Colors.grey.shade100,
      hoverColor: null,
    );
  }

  static ThemeData getDarkTheme(String languageCode) {
    final fontFamily = FontConstants.getFontFamily(languageCode);

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: ColorManager.darkBrown,
      scaffoldBackgroundColor: ColorManager.beige,

      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily),
        displayMedium: TextStyle(fontFamily: fontFamily),
        displaySmall: TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
        headlineSmall: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(color: ColorManager.white, fontWeight: FontWeight.bold, fontFamily: fontFamily),
        titleMedium: TextStyle(fontFamily: fontFamily),
        titleSmall: TextStyle(fontFamily: fontFamily),
        bodyLarge: const TextStyle(color: ColorManager.lightGray),
        bodyMedium: const TextStyle(color: ColorManager.lighterGray),
        bodySmall: const TextStyle(color: ColorManager.lightGray),
        labelLarge: TextStyle(fontFamily: fontFamily),
        labelMedium: TextStyle(fontFamily: fontFamily),
        labelSmall: TextStyle(fontFamily: fontFamily),
      ),
      colorScheme: const ColorScheme.dark(
        primary: ColorManager.darkBrown,
        secondary: ColorManager.darkLightBrown,
        surface: ColorManager.darkBeige,
        onPrimary: ColorManager.white,
        onSecondary: ColorManager.white,
        onSurface: ColorManager.lightGray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.darkBrown,
          foregroundColor: ColorManager.white,
          disabledBackgroundColor: ColorManager.darkLightBrown,
          disabledForegroundColor: ColorManager.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorManager.darkLightBrown,
          textStyle: TextStyle(
            fontWeight: FontWeightManager.semiBold,
          ),
        ),
      ),
    );
  }

  // Backward compatibility - default to English
  static ThemeData get lightTheme => getLightTheme('en');
  static ThemeData get darkTheme => getDarkTheme('en');
}
