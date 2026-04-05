import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { system, light, dark }
class ThemeProvider extends ChangeNotifier {
  // State variables
  ThemeModeOption _themeMode = ThemeModeOption.system;
  ThemeModeOption get themeMode => _themeMode;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final pref = await SharedPreferences.getInstance();
    final themeIndex = pref.getInt('themeMode') ?? 0;
    _themeMode = ThemeModeOption.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(ThemeModeOption mode) async {
    _themeMode = mode;
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    await pref.setInt('themeMode', mode.index);
  }

  ThemeMode get flutterThemeMode => switch (_themeMode) {
    ThemeModeOption.light => ThemeMode.light,
    ThemeModeOption.dark => ThemeMode.dark,
    ThemeModeOption.system => ThemeMode.system
  };
}