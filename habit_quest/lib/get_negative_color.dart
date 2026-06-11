import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


Future<String> getNegativeColor() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString('negativeColorString') ?? Colors.red.toString();
}
