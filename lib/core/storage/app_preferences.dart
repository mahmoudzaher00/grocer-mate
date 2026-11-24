import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_mode_manager.dart';

const String _themeModeKey = 'PREFS_KEY_THEME_MODE';

class AppPreferences {
  AppPreferences._(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static Future<AppPreferences> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return AppPreferences._(sharedPreferences);
  }

  ThemeMode getAppThemeMode() {
    return ThemeManager.resolveThemeMode(_sharedPreferences.getString(_themeModeKey));
  }

  Future<bool> cacheThemeMode(ThemeMode themeMode) {
    final cacheValue = ThemeManager.cacheValueFor(themeMode);
    if (cacheValue == null) {
      return _sharedPreferences.remove(_themeModeKey);
    }
    return _sharedPreferences.setString(_themeModeKey, cacheValue);
  }

  Future<bool> setString({required String key, required String value}) {
    return _sharedPreferences.setString(key, value);
  }

  String? getString({required String key}) {
    final value = _sharedPreferences.get(key);
    return switch (value) {
      null => null,
      String value => value,
      _ => throw FormatException('Stored preference "$key" must be a string.'),
    };
  }

  Future<bool> remove({required String key}) {
    return _sharedPreferences.remove(key);
  }
}
