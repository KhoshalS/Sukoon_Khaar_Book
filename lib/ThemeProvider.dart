// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.dark;
//
//   ThemeMode get themeMode => _themeMode;
//
//   void toggleTheme(bool isDark) {
//     _themeMode = isDark ? ThemeData. : ThemeMode.light;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static bool isDark = false;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool? mode = prefs.getBool('theme')==null?false:prefs.getBool('theme');
    isDark = mode!;
    print("isDark_$isDark");
    _themeMode =mode? ThemeMode.dark:ThemeMode.light;


    notifyListeners();
  }
  // final theme = mode ?? 'system';

  // ThemeMode.values.firstWhere(
  //       (e) => e.toString() == 'ThemeMode.light',
  //   orElse: () => ThemeMode.system,
  // );
  // Future<bool> loadThemeBool() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('theme') == "dark";
  // }

  Future<void> setThemeMode(bool mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme', mode);
    print("_THEME__"+mode.toString().split('.').last);
    print("__THEME__"+mode.toString());
    isDark = mode;
    _themeMode =mode? ThemeMode.dark:ThemeMode.light;

    notifyListeners();
  }
}