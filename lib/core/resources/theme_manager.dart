import 'package:material_ui/material_ui.dart';

abstract final class ThemeManager {
  static const String lightValue = 'light';
  static const String darkValue = 'dark';

  static ThemeMode resolveThemeMode(String? cachedValue) {
    return switch (cachedValue?.trim().toLowerCase()) {
      ThemeManager.lightValue => ThemeMode.light,
      ThemeManager.darkValue => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String? cacheValueFor(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => lightValue,
      ThemeMode.dark => darkValue,
      ThemeMode.system => null,
    };
  }

  static ThemeMode oppositeOf(Brightness brightness) {
    return brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
