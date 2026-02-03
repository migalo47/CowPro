import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // carga al iniciar
  }

  Future<void> _loadTheme() async {
    final value = await _storage.read(key: 'theme_mode');
    if (value == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(key: 'theme_mode', value: isDark ? 'dark' : 'light');
    notifyListeners();
  }
}
