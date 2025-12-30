import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontConstants {
  static const String fontFamily = "Poppins";
  static const String arabicFontFamily = "Tajawal";

  static String getFontFamily(String languageCode) {
    return languageCode == 'ar' ? arabicFontFamily : fontFamily;
  }
}

class FontWeightManager {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w900;
  static const FontWeight semiBold = FontWeight.w600;
}

class FontSize {
  static double s12 = 12.sp;
  static double s14 = 14.sp;
  static double s16 = 16.sp;
  static double s18 = 18.sp;
  static double s20 = 20.sp;
  static double s22 = 22.sp;
  static double s24 = 24.sp;
  static double s26 = 26.sp;
  static double s28 = 28.sp;
}