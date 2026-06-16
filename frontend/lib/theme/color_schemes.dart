import 'package:flutter/material.dart';

class EVColorSchemes {
  EVColorSchemes._();

  // Primary Green
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryGreenLight = Color(0xFF69F0AE);
  static const Color primaryGreenDark = Color(0xFF00A844);
  static const Color onPrimaryGreen = Color(0xFFFFFFFF);

  // Secondary Blue
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlueLight = Color(0xFF64B5F6);
  static const Color secondaryBlueDark = Color(0xFF1976D2);
  static const Color onSecondaryBlue = Color(0xFFFFFFFF);

  // Tertiary
  static const Color tertiaryAmber = Color(0xFFFFC107);
  static const Color tertiaryPurple = Color(0xFF7C4DFF);

  // Status Colors
  static const Color available = Color(0xFF00C853);
  static const Color occupied = Color(0xFFFF9800);
  static const Color offline = Color(0xFFF44336);
  static const Color maintenance = Color(0xFF9E9E9E);

  // Neutral
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Rating Colors
  static const Color ratingExcellent = Color(0xFF4CAF50);
  static const Color ratingGood = Color(0xFF8BC34A);
  static const Color ratingAverage = Color(0xFFFFC107);
  static const Color ratingPoor = Color(0xFFFF9800);
  static const Color ratingBad = Color(0xFFF44336);

  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryGreen,
    onPrimary: onPrimaryGreen,
    primaryContainer: primaryGreenLight,
    onPrimaryContainer: primaryGreenDark,
    secondary: secondaryBlue,
    onSecondary: onSecondaryBlue,
    secondaryContainer: secondaryBlueLight,
    onSecondaryContainer: secondaryBlueDark,
    tertiary: tertiaryAmber,
    onTertiary: Colors.black,
    tertiaryContainer: tertiaryAmber.withValues(alpha: 0.3),
    onTertiaryContainer: Colors.brown,
    error: const Color(0xFFB00020),
    onError: Colors.white,
    errorContainer: const Color(0xFFFCD8DF),
    onErrorContainer: const Color(0xFF410002),
    background: backgroundLight,
    onBackground: textPrimary,
    surface: surfaceLight,
    onSurface: textPrimary,
    surfaceVariant: const Color(0xFFE7E0EC),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: const Color(0xFFCAC4D0),
    shadow: Colors.black26,
    scrim: Colors.black54,
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: primaryGreenLight,
  );

  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryGreenLight,
    onPrimary: const Color(0xFF003915),
    primaryContainer: primaryGreenDark,
    onPrimaryContainer: primaryGreenLight,
    secondary: secondaryBlueLight,
    onSecondary: const Color(0xFF003258),
    secondaryContainer: secondaryBlueDark,
    onSecondaryContainer: secondaryBlueLight,
    tertiary: tertiaryAmber,
    onTertiary: Colors.black,
    tertiaryContainer: tertiaryAmber.withValues(alpha: 0.3),
    onTertiaryContainer: Colors.amberAccent,
    error: const Color(0xFFCF6679),
    onError: const Color(0xFF601410),
    errorContainer: const Color(0xFF8C1D18),
    onErrorContainer: const Color(0xFFFCD8DF),
    background: backgroundDark,
    onBackground: textOnDark,
    surface: surfaceDark,
    onSurface: textOnDark,
    surfaceVariant: const Color(0xFF49454F),
    onSurfaceVariant: const Color(0xFFCAC4D0),
    outline: const Color(0xFF938F99),
    outlineVariant: const Color(0xFF49454F),
    shadow: Colors.black54,
    scrim: Colors.black87,
    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: primaryGreen,
  );
}
