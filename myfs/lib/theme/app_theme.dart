import 'package:flutter/material.dart';

/// Bảng màu & theme dùng chung toàn app (tông cam – phong cách eNetViet/FPT).
class AppColors {
  static const primary      = Color(0xFFF26F21); // Cam FPT chuẩn
  static const primaryDark  = Color(0xFFC7510F);
  static const primaryLight = Color(0xFFF7A87A);
  static const border       = Color(0xFFE2E8F0);
  static const surfaceTint  = Color(0xFFFEF3EC);
  static const background   = Color(0xFFF8FAFC); // Nền xám nhạt (Tailwind Slate 50)
  static const ink          = Color(0xFF0F172A); // Chữ đen đậm
  static const inkLight     = Color(0xFF64748B); // Chữ xám
  static const danger       = Color(0xFFEF4444);
  static const success      = Color(0xFF10B981);
  static const warning      = Color(0xFFF59E0B);
  static const info         = Color(0xFF3B82F6);

  /// Màu badge theo điểm chữ (A, B+, ... F).
  static Color gradeBadge(String letter) {
    switch (letter) {
      case 'A':  return const Color(0xFF4CAF50);
      case 'B+': return const Color(0xFF2196F3);
      case 'B':  return const Color(0xFF03A9F4);
      case 'C+': return const Color(0xFFFFC107);
      case 'C':  return const Color(0xFFFF9800);
      case 'D+': return const Color(0xFFFF5722);
      case 'D':  return const Color(0xFFF44336);
      default:   return const Color(0xFFB71C1C);
    }
  }
}

/// Theme tổng của ứng dụng (giữ nguyên phong cách màn hình Login gốc).
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto', // FPT cũng hay dùng Roboto hoặc Inter
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: Colors.white,
      onSurface: AppColors.ink,
      surfaceTint: Colors.transparent, // Tắt màu ám hồng của Material 3
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 2.0),
      ),
      labelStyle: const TextStyle(color: AppColors.inkLight),
      hintStyle: const TextStyle(color: AppColors.border),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primaryLight,
        minimumSize: const Size.fromHeight(56), // 8-pt grid (56px)
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
