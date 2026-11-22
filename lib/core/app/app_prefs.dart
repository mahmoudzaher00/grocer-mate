import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../resources/theme_manager.dart';

const String PREFS_KEY_LANG = 'PREFS_KEY_LANG';
const String PREFS_KEY_THEME_MODE = 'PREFS_KEY_THEME_MODE';
const String PREFS_KEY_ONBOARDING_VIEWED = 'PREFS_KEY_ONBOARDING_VIEWED';
const String PREFS_KEY_SET_LOCATION_SCREEN_VIEWED =
    'PREFS_KEY_SET_LOCATION_SCREEN_VIEWED';
const String PREFS_KEY_SET_SHOW_CASE_VIEWED = 'PREFS_KEY_SET_SHOW_CASE_VIEWED';
const String PREFS_KEY_IS_USER_LOGGED_IN = 'PREFS_KEY_IS_USER_LOGGED_IN';
const String PREFS_KEY_PROFILE = 'PREFS_KEY_PROFILE';
const String PREFS_KEY_TOKEN = 'ACCESS_TOKEN';
const String PREFS_KEY_REFRESH_TOKEN = 'REFRESH_TOKEN';
const String PREFS_KEY_REFRESH_TOKEN_EXPIRATION = 'REFRESH_TOKEN_EXPIRATION';
const String PREFS_KEY_ACTIVE_DELEGATED_USER_ID = 'ACTIVE_DELEGATED_USER_ID';
const String PREFS_KEY_ORIGINAL_AUTHENTICATED_USER_ID = 'ORIGINAL_AUTHENTICATED_USER_ID';
const String PREFS_KEY_PUSH_NOTIFICATION_ENABLED =
    'PREFS_KEY_PUSH_NOTIFICATION_ENABLED';
const String PREFS_KEY_TASKS_BOX = 'TASKS_BOX';
const String PREFS_KEY_IS_START_TRACKING = 'PREFS_KEY_IS_START_TRACKING';
const String PREFS_KEY_IS_END_TRACKING = 'PREFS_KEY_IS_END_TRACKING';
const String PREFS_KEY_USER_CLAIMS_BOX = 'USER_CLAIMS_BOX';
const String PREFS_KEY_USER_CLAIMS = 'USER_CLAIMS';
const String PREFS_KEY_OBSERVATIONS_BOX = 'OBSERVATIONS_BOX';
const String PREFS_KEY_OBSERVATIONS = 'OBSERVATIONS';

class AppPreferences {
  // AppPreferences() {_initPreferences();}
  //
  // /// Internal shared and secure storage references
  // late final SharedPreferences _sharedPreferences;
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  //
  // /// Initializes SharedPreferences asynchronously once
  // Future<void> _initPreferences() async => _sharedPreferences = await SharedPreferences.getInstance();
  AppPreferences._(this._sharedPreferences);

  /// Internal shared and secure storage references
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool get hasRequestedNotificationPermission => _sharedPreferences.getBool('notification_permission_requested') ?? false;

  Future<void> setNotificationPermissionRequested() async => _sharedPreferences.setBool('notification_permission_requested', true);

  List<String> get notificationTopics => _sharedPreferences.getStringList('notification_topics') ?? const [];

  List<String> get knownNotificationTopics => _sharedPreferences.getStringList('notification_known_topics') ?? const [];

  Future<void> setNotificationTopics(List<String> topics) async => _sharedPreferences.setStringList('notification_topics', topics);

  Future<void> setKnownNotificationTopics(List<String> topics) async => _sharedPreferences.setStringList('notification_known_topics', topics);

  bool get isPushNotificationEnabled =>
      _sharedPreferences.getBool(PREFS_KEY_PUSH_NOTIFICATION_ENABLED) ?? false;

  Future<void> setPushNotificationEnabled(bool isEnabled) async =>
      _sharedPreferences.setBool(PREFS_KEY_PUSH_NOTIFICATION_ENABLED, isEnabled);

  ///  Create once (async) so SharedPreferences is guaranteed ready
  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences._(prefs);
  }

  /// Theme Settings ###########################################################
  ThemeMode getAppThemeMode() {
    return ThemeManager.resolveThemeMode(
      _sharedPreferences.getString(PREFS_KEY_THEME_MODE),
    );
  }

  Future<bool> cacheThemeMode(ThemeMode themeMode) {
    final cacheValue = ThemeManager.cacheValueFor(themeMode);
    if (cacheValue == null) {
      return _sharedPreferences.remove(PREFS_KEY_THEME_MODE);
    }
    return _sharedPreferences.setString(PREFS_KEY_THEME_MODE, cacheValue);
  }

  /// SharedPreferences helpers ################################################
  Future<void> setOnBoardingViewed() async {
    await _sharedPreferences.setBool(PREFS_KEY_ONBOARDING_VIEWED, true);
  }
  bool get isOnBoardingViewed => _sharedPreferences.getBool(PREFS_KEY_ONBOARDING_VIEWED) ?? false;


  // Save any data type (String, int, bool, double) in shared preferences
  Future<bool> saveToPreferences({
    required dynamic value,
    required String key,
  }) async {
    if (value is String) return await _sharedPreferences.setString(key, value);
    if (value is int) return await _sharedPreferences.setInt(key, value);
    if (value is bool) return await _sharedPreferences.setBool(key, value);
    return await _sharedPreferences.setDouble(key, value);
  }

  // Retrieve data from shared preferences by key
  dynamic getFromPreferences({required String key}) =>
      _sharedPreferences.get(key);

  // Clear data from shared preferences by key
  Future<bool> clearDataFromSharedPreference({required String key}) async =>
      await _sharedPreferences.remove(key);
  // Clear all data from shared preferences
  Future<bool> clearAllPreferences() async => await _sharedPreferences.clear();

  /// FlutterSecureStorage helpers #############################################
  // Write a secure key-value pair (for tokens, etc.)
  Future<void> saveSecure({required String key, String? value}) async =>
      await _secureStorage.write(key: key, value: value);

  // Read a value from secure storage
  Future<String?> readSecure({required String key}) async =>
      _secureStorage.read(key: key);

  // Delete a single key from secure storage
  Future<void> deleteSecure(String key) async =>
      await _secureStorage.delete(key: key);

  // Delete all secure data (clears all tokens)
  Future<void> clearAllSecure() async => await _secureStorage.deleteAll();

  /// User Session #############################################################

  // Token Caching Methods
  Future<void> cacheToken(String token) async =>
      await _secureStorage.write(key: PREFS_KEY_TOKEN, value: token);

  Future<void> cacheRefreshToken(String refreshToken) async =>
      await _secureStorage.write(
        key: PREFS_KEY_REFRESH_TOKEN,
        value: refreshToken,
      );

  Future<void> cacheSessionTokens({
    required String accessToken,
    required String refreshToken,
    String? refreshTokenExpiration,
    String? originalAuthenticatedUserId,
  }) async {
    await cacheRefreshToken(refreshToken);
    await _secureStorage.write(
      key: PREFS_KEY_REFRESH_TOKEN_EXPIRATION,
      value: refreshTokenExpiration,
    );
    await _secureStorage.write(key: PREFS_KEY_ORIGINAL_AUTHENTICATED_USER_ID, value: originalAuthenticatedUserId);
    await cacheToken(accessToken);
  }
  // Retrieve cached  token, if available
  Future<String?> getCachedToken() async =>
      await _secureStorage.read(key: PREFS_KEY_TOKEN);

  // Retrieve cached refresh token, if available
  Future<String?> getCachedRefreshToken() async =>
      await _secureStorage.read(key: PREFS_KEY_REFRESH_TOKEN);

  Future<String?> getOriginalAuthenticatedUserId() async =>
      await _secureStorage.read(key: PREFS_KEY_ORIGINAL_AUTHENTICATED_USER_ID);

  Future<void> cacheActiveDelegatedUserId(String userId) async =>
      await _secureStorage.write(
        key: PREFS_KEY_ACTIVE_DELEGATED_USER_ID,
        value: userId,
      );

  Future<String?> getCachedActiveDelegatedUserId() async =>
      await _secureStorage.read(key: PREFS_KEY_ACTIVE_DELEGATED_USER_ID);

  Future<void> clearActiveDelegatedUserId() async =>
      await _secureStorage.delete(key: PREFS_KEY_ACTIVE_DELEGATED_USER_ID);

  // Remove cached token
  Future<void> clearToken() async =>
      await _secureStorage.delete(key: PREFS_KEY_TOKEN);

  Future<void> clearUserSession() async {
    await _secureStorage.delete(key: PREFS_KEY_ORIGINAL_AUTHENTICATED_USER_ID);
    await _secureStorage.delete(key: PREFS_KEY_TOKEN);
    await _secureStorage.delete(key: PREFS_KEY_REFRESH_TOKEN);
    await _secureStorage.delete(key: PREFS_KEY_REFRESH_TOKEN_EXPIRATION);
    await _secureStorage.delete(key: PREFS_KEY_ACTIVE_DELEGATED_USER_ID);
    await _sharedPreferences.remove(PREFS_KEY_IS_USER_LOGGED_IN);
  }

  // Set user as logged in
  Future<void> setUserLoggedIn() async =>
      await _sharedPreferences.setBool(PREFS_KEY_IS_USER_LOGGED_IN, true);

  // Check if user is logged in
  bool get isUserLoggedIn =>
      _sharedPreferences.getBool(PREFS_KEY_IS_USER_LOGGED_IN) ?? false;

  /// Logout: clear secure tokens + shared prefs
  Future<void> logout() async {
    await clearAllSecure();
    await clearAllPreferences();
  }

  /// Handles logout when refresh token authentication fails
  Future<void> handleUnauthenticatedLogout() async {
    await _secureStorage.delete(key: PREFS_KEY_ORIGINAL_AUTHENTICATED_USER_ID);
    await _secureStorage.delete(key: PREFS_KEY_TOKEN);
    await _secureStorage.delete(key: PREFS_KEY_REFRESH_TOKEN);
    await _secureStorage.delete(key: PREFS_KEY_REFRESH_TOKEN_EXPIRATION);
    await _secureStorage.delete(key: PREFS_KEY_ACTIVE_DELEGATED_USER_ID);

    await clearAllPreferences();
  }
}
