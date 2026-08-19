import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ColorThemeProvider extends ChangeNotifier {
  // [pos, neg]
  List<int> _colorThemes = [
    Colors.green.toARGB32(),
    Colors.red.toARGB32(),
  ];
  List<int> get colorThemes => _colorThemes;

  ColorThemeProvider() {
    _loadColorPrefs();
  }

  Future<void> _loadColorPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final int posColor = prefs.getInt('positiveColorInt') ?? Colors.green.toARGB32();
    final int negColor = prefs.getInt('negativeColorInt') ?? Colors.red.toARGB32();

    _colorThemes = [posColor, negColor];
    notifyListeners();
  }
  Future<void> setColors(List<int> colorList) async {
    final posColor = colorList[0];
    final negColor = colorList[1];

    _colorThemes = [posColor, negColor];
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    await pref.setInt('positiveColorInt', posColor);
    await pref.setInt('negativeColorInt', negColor);
  }
}
