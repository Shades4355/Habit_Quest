import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


Future<String> getPositiveColor() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString('positiveColorString') ?? Colors.green.toString();
}
