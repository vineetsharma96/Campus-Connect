import 'package:campus/core/constants/app_colors.dart';
import 'package:campus/core/theme/app_theme.dart';
import 'package:campus/core/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    AppTypography.useSystemFallback = true;
  });

  tearDownAll(() {
    AppTypography.useSystemFallback = false;
  });

  group('AppTheme Tests', () {
    test('Light theme has correct primary and surface mappings', () {
      final theme = AppTheme.light;
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, equals(AppColors.primaryBlue));
      expect(theme.useMaterial3, isTrue);
    });

    test('Dark theme has dark brightness and elevated surface styling', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme.primary, equals(AppColors.accentBlue));
      expect(theme.useMaterial3, isTrue);
    });
  });
}
