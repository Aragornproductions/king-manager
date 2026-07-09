import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  static const _prefKey = 'selected_theme_index';

  int get selectedIndex => _selectedIndex;
  AppTheme get currentTheme => kAppThemes[_selectedIndex];

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedIndex = prefs.getInt(_prefKey) ?? 0;
    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    _selectedIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, index);
  }
}
