import 'package:flutter/material.dart';

/// Bảng màu & theme dùng chung toàn app (tông cam – phong cách eNetViet/FPT).
class AppColors {
  static const primary = Color(0xFFF26F21); // Cam FPT chuẩn
  static const primaryDark = Color(0xFFC7510F);
  static const primaryLight = Color(0xFFF7A87A);
  static const border = Color(0xFFE2E8F0);
  static const surfaceTint = Color(0xFFFEF3EC);
  static const background = Color(
    0xFFF8FAFC,
  ); // Nền xám nhạt (Tailwind Slate 50)
  static const ink = Color(0xFF0F172A); // Chữ đen đậm
  static const inkLight = Color(0xFF64748B); // Chữ xám
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const navy = Color(0xFF172A46);
  static const surfaceSoft = Color(0xFFF1F5F9);

  /// Màu badge theo điểm chữ (A, B+, ... F).
  static Color gradeBadge(String letter) {
    switch (letter) {
      case 'A':
        return const Color(0xFF4CAF50);
      case 'B+':
        return const Color(0xFF2196F3);
      case 'B':
        return const Color(0xFF03A9F4);
      case 'C+':
        return const Color(0xFFFFC107);
      case 'C':
        return const Color(0xFFFF9800);
      case 'D+':
        return const Color(0xFFFF5722);
      case 'D':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFB71C1C);
    }
  }
}

/// Theme tổng của ứng dụng (giữ nguyên phong cách màn hình Login gốc).
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    surface: Colors.white,
    onSurface: AppColors.ink,
    surfaceTint: Colors.transparent,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto', // FPT cũng hay dùng Roboto hoặc Inter
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: scheme,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: AppColors.ink),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: AppColors.inkLight,
      ),
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
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shadowColor: AppColors.inkLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 0.7),
      ),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      iconColor: AppColors.inkLight,
      titleTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: AppColors.inkLight,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 0.8,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceSoft,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}
