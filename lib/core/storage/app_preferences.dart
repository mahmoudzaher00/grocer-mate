import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart' show PlatformException;
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_mode_manager.dart';

const String _themeModeKey = 'PREFS_KEY_THEME_MODE';

/// Platform acknowledgements do not guarantee crash-durable persistence.
final class AppPreferences {
  AppPreferences._(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;
  Future<void> _operationTail = Future<void>.value();
  ({String key, Object? value})? _pendingRepair;

  static Future<AppPreferences> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return AppPreferences._(sharedPreferences);
  }

  ThemeMode getAppThemeMode() {
    return ThemeModeManager.resolveThemeMode(_sharedPreferences.getString(_themeModeKey));
  }

  Future<bool> cacheThemeMode(ThemeMode themeMode) {
    final cacheValue = ThemeModeManager.cacheValueFor(themeMode);
    if (cacheValue == null) {
      return remove(key: _themeModeKey);
    }
    return setString(key: _themeModeKey, value: cacheValue);
  }

  Future<bool> setString({required String key, required String value}) {
    return _runVerified(() => _mutate(key, () => _sharedPreferences.setString(key, value)));
  }

  Future<String?> getString({required String key}) {
    return _runVerified(() => _readString(key));
  }

  Future<bool> updateString({required String key, required String Function(String? currentValue) update}) {
    return _runVerified(() {
      final value = update(_readString(key));
      return _mutate(key, () => _sharedPreferences.setString(key, value));
    });
  }

  Future<bool> remove({required String key}) {
    return _runVerified(() => _mutate(key, () => _sharedPreferences.remove(key)));
  }

  String? _readString(String key) {
    final value = _sharedPreferences.get(key);
    return switch (value) {
      null => null,
      String value => value,
      _ => throw FormatException('Stored preference "$key" must be a string.'),
    };
  }

  Future<T> _runVerified<T>(FutureOr<T> Function() operation) async {
    final previousOperation = _operationTail;
    final release = Completer<void>();
    _operationTail = release.future;

    await previousOperation;
    try {
      if (!await _tryRepairPending()) {
        throw PlatformException(code: 'preferences_unverified', message: 'Stored data could not be verified. Please try again.');
      }
      return await operation();
    } finally {
      release.complete();
    }
  }

  Future<bool> _mutate(String key, Future<bool> Function() mutation) async {
    final previousValue = _sharedPreferences.get(key);
    _pendingRepair = (key: key, value: previousValue is List ? List<String>.from(previousValue) : previousValue);

    try {
      final didWrite = await mutation();
      if (didWrite) {
        _pendingRepair = null;
        return true;
      }
    } on Object {
      await _tryRepairPending();
      rethrow;
    }

    await _tryRepairPending();
    return false;
  }

  Future<bool> _tryRepairPending() async {
    final repair = _pendingRepair;
    if (repair == null) return true;

    try {
      // Reload alone can return a backend cache containing the failed mutation.
      if (!await _restoreValue(repair.key, repair.value)) return false;
      await _sharedPreferences.reload();

      final restoredValue = _sharedPreferences.get(repair.key);
      final expectedValue = repair.value;
      final matches = expectedValue is List<String> ? restoredValue is List && listEquals(restoredValue, expectedValue) : restoredValue == expectedValue;
      if (!matches) return false;

      _pendingRepair = null;
      return true;
    } on Object {
      // Retain the repair so later operations cannot use unverified storage.
      return false;
    }
  }

  Future<bool> _restoreValue(String key, Object? value) {
    return switch (value) {
      null => _sharedPreferences.remove(key),
      String value => _sharedPreferences.setString(key, value),
      bool value => _sharedPreferences.setBool(key, value),
      int value => _sharedPreferences.setInt(key, value),
      double value => _sharedPreferences.setDouble(key, value),
      List<String> value => _sharedPreferences.setStringList(key, value),
      _ => throw StateError('The previous preference value could not be restored.'),
    };
  }
}
