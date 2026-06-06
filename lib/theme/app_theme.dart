import 'package:flutter/material.dart';

import 'bichar_theme_extension.dart';

/// Central light and dark [ThemeData] definitions for Bichar Setu.
class AppTheme {
  AppTheme._();

  static const Color _accent = Color(0xFF6A3DE8);
  static const Color _accentLight = Color(0xFF8B6EFF);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: BicharTheme.light.textPrimary,
      onSurfaceVariant: BicharTheme.light.textSecondary,
      outline: BicharTheme.light.border,
    );

    return _baseTheme(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackground: const Color(0xFFF7F7FB),
      extension: BicharTheme.light,
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentLight,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1A2A),
      onSurface: BicharTheme.dark.textPrimary,
      onSurfaceVariant: BicharTheme.dark.textSecondary,
      outline: BicharTheme.dark.border,
    );

    return _baseTheme(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackground: const Color(0xFF121018),
      extension: BicharTheme.dark,
    );
  }

  static ThemeData _baseTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color scaffoldBackground,
    required BicharTheme extension,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: [extension],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: extension.cardBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: extension.textPrimary,
        iconTheme: IconThemeData(color: extension.textPrimary),
        titleTextStyle: TextStyle(
          color: extension.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: extension.cardBackground,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: extension.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: extension.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: extension.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: extension.textSecondary,
          fontSize: 15,
          height: 1.4,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: extension.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: extension.cardBackground,
        indicatorColor: extension.chipBackground,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? extension.accent : extension.textPrimary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? extension.accent : extension.textPrimary,
          );
        }),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: extension.drawerBackground,
      ),
      dividerTheme: DividerThemeData(
        color: extension.border,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: extension.textPrimary),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: extension.textPrimary),
        bodyMedium: TextStyle(color: extension.textSecondary),
        titleLarge: TextStyle(
          color: extension.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: extension.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.searchFieldBackground,
        hintStyle: TextStyle(
          color: extension.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: extension.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: extension.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: extension.accent, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: extension.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: extension.accent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return extension.accent;
          }
          return isDark ? Colors.grey.shade400 : Colors.grey.shade300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return extension.accent.withValues(alpha: 0.45);
          }
          return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2540) : extension.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: extension.accent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: extension.accent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
