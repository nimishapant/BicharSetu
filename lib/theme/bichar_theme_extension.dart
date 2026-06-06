import 'package:flutter/material.dart';

/// Semantic colors shared across Bichar Setu screens.
/// Access via `context.bichar` (see [BicharThemeX]).
@immutable
class BicharTheme extends ThemeExtension<BicharTheme> {
  const BicharTheme({
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accent,
    required this.accentLight,
    required this.chipBackground,
    required this.searchFieldBackground,
    required this.drawerBackground,
    required this.cardBackground,
    required this.mutedIcon,
    required this.headerTint,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color accent;
  final Color accentLight;
  final Color chipBackground;
  final Color searchFieldBackground;
  final Color drawerBackground;
  final Color cardBackground;
  final Color mutedIcon;
  final Color headerTint;

  static const BicharTheme light = BicharTheme(
    textPrimary: Color(0xFF1D1A29),
    textSecondary: Color(0xFF7A7690),
    border: Color(0xFFF0EDF7),
    accent: Color(0xFF6A3DE8),
    accentLight: Color(0xFF8B6EFF),
    chipBackground: Color(0xFFF2EEFF),
    searchFieldBackground: Color(0xFFEFF1F5),
    drawerBackground: Color(0xFFF3F3F5),
    cardBackground: Colors.white,
    mutedIcon: Color(0xFF7E8292),
    headerTint: Color(0xFFFFF0F0),
  );

  static const BicharTheme dark = BicharTheme(
    textPrimary: Color(0xFFF4F2FA),
    textSecondary: Color(0xFFA8A3B8),
    border: Color(0xFF2E2A3D),
    accent: Color(0xFF8B6EFF),
    accentLight: Color(0xFFA78BFA),
    chipBackground: Color(0xFF2A2440),
    searchFieldBackground: Color(0xFF252033),
    drawerBackground: Color(0xFF16131F),
    cardBackground: Color(0xFF1E1A2A),
    mutedIcon: Color(0xFF9E99AE),
    headerTint: Color(0xFF2A1F28),
  );

  @override
  BicharTheme copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? accent,
    Color? accentLight,
    Color? chipBackground,
    Color? searchFieldBackground,
    Color? drawerBackground,
    Color? cardBackground,
    Color? mutedIcon,
    Color? headerTint,
  }) {
    return BicharTheme(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      chipBackground: chipBackground ?? this.chipBackground,
      searchFieldBackground: searchFieldBackground ?? this.searchFieldBackground,
      drawerBackground: drawerBackground ?? this.drawerBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      mutedIcon: mutedIcon ?? this.mutedIcon,
      headerTint: headerTint ?? this.headerTint,
    );
  }

  @override
  BicharTheme lerp(ThemeExtension<BicharTheme>? other, double t) {
    if (other is! BicharTheme) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return BicharTheme(
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      border: lerpColor(border, other.border),
      accent: lerpColor(accent, other.accent),
      accentLight: lerpColor(accentLight, other.accentLight),
      chipBackground: lerpColor(chipBackground, other.chipBackground),
      searchFieldBackground:
          lerpColor(searchFieldBackground, other.searchFieldBackground),
      drawerBackground: lerpColor(drawerBackground, other.drawerBackground),
      cardBackground: lerpColor(cardBackground, other.cardBackground),
      mutedIcon: lerpColor(mutedIcon, other.mutedIcon),
      headerTint: lerpColor(headerTint, other.headerTint),
    );
  }
}

extension BicharThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  BicharTheme get bichar => theme.extension<BicharTheme>() ?? BicharTheme.light;
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
