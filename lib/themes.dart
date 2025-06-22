// // themes.dart
// import 'package:flutter/material.dart';
//
// import 'CustomColors.dart';
//
// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   extensions: <ThemeExtension<dynamic>>[
//     const CustomColors(abc: Color(0xFF4A90E2)), // bluish
//   ],
// );
//
// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   extensions: <ThemeExtension<dynamic>>[
//     const CustomColors(abc: Color(0xFFFFD54F)), // yellowish
//   ],
// );

import 'package:flutter/material.dart';
import 'AppColors.dart';

ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      secondary: AppColors.lightSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onSurface: AppColors.lightOnSurface,
      onBackground: AppColors.lightOnBackground,
      onError: AppColors.lightOnError,
      surfaceVariant: AppColors.lightSurfaceVariant,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onSurface: AppColors.darkOnSurface,
      onBackground: AppColors.darkOnBackground,
      onError: AppColors.darkOnError,
      surfaceVariant: AppColors.darkSurfaceVariant,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
    ),
  );
}

// import 'package:flutter/material.dart';
//
// import 'AppColors.dart';
//
// ThemeData _buildLightTheme() {
//   return ThemeData(
//     useMaterial3: true, // Important for new Material Design
//     brightness: Brightness.light,
//     colorScheme: ColorScheme.light(
//       primary: AppColors.lightPrimary,
//       primaryContainer: AppColors.lightPrimaryContainer,
//       secondary: AppColors.lightSecondary,
//       secondaryContainer: AppColors.lightSecondaryContainer,
//       surface: AppColors.lightSurface,
//       background: AppColors.lightBackground,
//       error: AppColors.lightError,
//       onPrimary: AppColors.lightOnPrimary,
//       onSecondary: AppColors.lightOnSecondary,
//       onSurface: AppColors.lightOnSurface,
//       onBackground: AppColors.lightOnBackground,
//       onError: AppColors.lightOnError,
//       surfaceVariant: AppColors.lightSurfaceVariant,
//     ),
//     // Additional theme customizations
//     appBarTheme: AppBarTheme(
//       backgroundColor: AppColors.lightPrimary,
//       foregroundColor: AppColors.lightOnPrimary,
//     ),
//   );
// }
//
// ThemeData _buildDarkTheme() {
//   return ThemeData(
//     useMaterial3: true, // Important for new Material Design
//     brightness: Brightness.dark,
//     colorScheme: ColorScheme.dark(
//       primary: AppColors.darkPrimary,
//       primaryContainer: AppColors.darkPrimaryContainer,
//       secondary: AppColors.darkSecondary,
//       secondaryContainer: AppColors.darkSecondaryContainer,
//       surface: AppColors.darkSurface,
//       background: AppColors.darkBackground,
//       error: AppColors.darkError,
//       onPrimary: AppColors.darkOnPrimary,
//       onSecondary: AppColors.darkOnSecondary,
//       onSurface: AppColors.darkOnSurface,
//       onBackground: AppColors.darkOnBackground,
//       onError: AppColors.darkOnError,
//       surfaceVariant: AppColors.darkSurfaceVariant,
//     ),
//     // Additional theme customizations
//     appBarTheme: AppBarTheme(
//       backgroundColor: AppColors.darkSurface,
//       foregroundColor: AppColors.darkOnSurface,
//     ),
//   );
// }