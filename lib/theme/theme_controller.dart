import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme controller — persists the user's [ThemeMode], accent color, language, font, and text size.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  factory ThemeController() => instance;

  static const String _prefThemeMode = 'bichar_theme_mode';
  static const String _prefLanguage = 'bichar_language';
  static const String _prefAccentColor = 'bichar_accent_color';
  static const String _prefFontFamily = 'bichar_font_family';
  static const String _prefTextScale = 'bichar_text_scale';

  ThemeMode _themeMode = ThemeMode.light;
  Locale? _locale;
  Color _accentColor = const Color(0xFF6A3DE8); // Default Purple
  String _fontFamily = 'Default';
  double _textScaleFactor = 1.0; // Medium

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  Color get accentColor => _accentColor;
  String get fontFamily => _fontFamily;
  double get textScaleFactor => _textScaleFactor;

  /// `true` when dark mode is explicitly enabled.
  bool get isDarkModeEnabled => _themeMode == ThemeMode.dark;

  /// Load saved preferences. Call once before [runApp].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parseThemeMode(prefs.getString(_prefThemeMode));
    _locale = _parseLocale(prefs.getString(_prefLanguage));
    _accentColor = Color(prefs.getInt(_prefAccentColor) ?? 0xFF6A3DE8);
    _fontFamily = prefs.getString(_prefFontFamily) ?? 'Default';
    _textScaleFactor = prefs.getDouble(_prefTextScale) ?? 1.0;
    notifyListeners();
  }

  /// Toggle between light and dark (used by the Settings switch).
  Future<void> setDarkModeEnabled(bool enabled) {
    return setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  /// Set any supported [ThemeMode] and persist it.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, _encodeThemeMode(mode));
  }

  Future<void> setLanguage(String? languageCode) async {
    _locale = _parseLocale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null) {
      await prefs.remove(_prefLanguage);
    } else {
      await prefs.setString(_prefLanguage, languageCode);
    }
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;
    _accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefAccentColor, color.value);
  }

  Future<void> setFontFamily(String font) async {
    if (_fontFamily == font) return;
    _fontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFontFamily, font);
  }

  Future<void> setTextScaleFactor(double factor) async {
    if (_textScaleFactor == factor) return;
    _textScaleFactor = factor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefTextScale, factor);
  }

  String themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Currently using light theme.';
      case ThemeMode.dark:
        return 'Currently using dark theme.';
      case ThemeMode.system:
        return 'Following your device appearance.';
    }
  }

  String get currentThemeLabel => themeModeLabel(_themeMode);

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static String _encodeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  static Locale? _parseLocale(String? code) {
    if (code == null || code == 'system') return null;
    return Locale(code);
  }
}
