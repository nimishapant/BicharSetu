import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme controller — persists the user's [ThemeMode] locally.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  factory ThemeController() => instance;

  static const String _prefKey = 'bichar_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  /// `true` when dark mode is explicitly enabled.
  bool get isDarkModeEnabled => _themeMode == ThemeMode.dark;

  /// Load saved preference. Call once before [runApp].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parseThemeMode(prefs.getString(_prefKey));
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
    await prefs.setString(_prefKey, _encodeThemeMode(mode));
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
}
