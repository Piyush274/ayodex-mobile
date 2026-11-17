import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.base,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.base,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.heading,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: AppTextTheme.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.heading),
        titleTextStyle: AppTextTheme.headingMedium,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusCard,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p12,
        ),
        hintStyle: AppTextTheme.bodyMedium.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextTheme.bodyMedium.copyWith(color: AppColors.heading),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.base, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.base,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMedium,
          ),
          textStyle: AppTextTheme.button,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
