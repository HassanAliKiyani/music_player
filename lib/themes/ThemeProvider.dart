import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_player/themes/DarkMode.dart';
import 'package:music_player/themes/LightMode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDark => _themeData == darkMode;

  ThemeProvider() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    _themeData = isDarkMode ? darkMode : lightMode;
  }

  set themeData(ThemeData mode) {
    if (_themeData != mode) {
      _themeData = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeData == darkMode) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
  }
}
