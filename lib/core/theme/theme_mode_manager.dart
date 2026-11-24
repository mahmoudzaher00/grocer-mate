import 'package:material_ui/material_ui.dart';

abstract final class ThemeModeManager {
  static const String _lightValue = 'light';
  static const String _darkValue = 'dark';

  static ThemeMode resolveThemeMode(String? cachedValue) {
    return switch (cachedValue?.trim().toLowerCase()) {
      _lightValue => ThemeMode.light,
      _darkValue => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String? cacheValueFor(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => _lightValue,
      ThemeMode.dark => _darkValue,
      ThemeMode.system => null,
    };
  }

  static ThemeMode oppositeOf(Brightness brightness) {
    return brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
