import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ColorThemeProvider extends ChangeNotifier {
  List<String> _colorThemes = [
    Colors.green.toString(),
    Colors.red.toString(),
  ];
  List<String> get colorThemes => _colorThemes;

  ColorThemeProvider() {
    _loadColorPrefs();
  }

  Future<void> _loadColorPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final posColor = prefs.getString('positiveColorString') ?? Colors.green.toString();
    final negColor = prefs.getString('negativeColorString') ?? Colors.red.toString();

    List<String> _colorThemes = [posColor, negColor];
    notifyListeners();
  }
  Future<void> setColors(List<String> colorList) async {
    final posColor = colorList[0];
    final negColor = colorList[1];

    _colorThemes = [posColor, negColor];
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    await pref.setString('positiveColorString', posColor);
    await pref.setString('negativeColorString', negColor);
  }
}
