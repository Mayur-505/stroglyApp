import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle logoTitle({
    double fontSize = 42,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: 'LozangeNoCommercial',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryLime,
        letterSpacing: letterSpacing,
        height: 1.0,
      );

  static TextStyle tagline({double fontSize = 15}) => GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: AppColors.textWhite,
        letterSpacing: 0.2,
      );
}
