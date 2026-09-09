import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract final class AppTypography {
  /// When true, bypasses GoogleFonts asset/network loaders and returns standard TextStyles.
  /// Used in unit tests to eliminate asset bundle and network dependencies.
  @visibleForTesting
  static bool useSystemFallback = false;

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required double letterSpacing,
    required Color color,
  }) {
    if (useSystemFallback) {
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme textTheme(bool isDark) {
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: _font(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: primary,
      ),
      displayMedium: _font(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: primary,
      ),
      titleLarge: _font(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primary,
      ),
      titleMedium: _font(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      bodyLarge: _font(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: primary,
      ),
      bodyMedium: _font(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: secondary,
      ),
      labelLarge: _font(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelSmall: _font(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: secondary,
      ),
    );
  }
}
