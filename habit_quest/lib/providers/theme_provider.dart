import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool get darkMode => _darkMode;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final pref = await SharedPreferences.getInstance();
    _darkMode = pref.getBool('darkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('darkMode', value);
  }
}