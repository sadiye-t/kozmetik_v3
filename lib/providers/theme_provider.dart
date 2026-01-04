import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString("themeMode") ?? "system";
    _mode = v == "dark"
        ? ThemeMode.dark
        : v == "light"
            ? ThemeMode.light
            : ThemeMode.system;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "themeMode",
      mode == ThemeMode.dark
          ? "dark"
          : mode == ThemeMode.light
              ? "light"
              : "system",
    );
    notifyListeners();
  }
}
