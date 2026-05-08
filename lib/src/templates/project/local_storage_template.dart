/// Returns the local_storage.dart content for core/storage/.
String localStorageTemplate() => r'''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage.g.dart';

/// Secure storage provider for sensitive data (tokens, keys).
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

/// Shared preferences provider for non-sensitive data.
@riverpod
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) {
  return SharedPreferences.getInstance();
}

/// Helper class for common storage operations.
class LocalStorage {
  const LocalStorage(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  // ── Secure Storage (tokens) ──────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _secure.write(key: 'access_token', value: token);

  Future<String?> getToken() => _secure.read(key: 'access_token');

  Future<void> saveRefreshToken(String token) =>
      _secure.write(key: 'refresh_token', value: token);

  Future<String?> getRefreshToken() => _secure.read(key: 'refresh_token');

  Future<void> clearTokens() async {
    await _secure.delete(key: 'access_token');
    await _secure.delete(key: 'refresh_token');
  }

  // ── Shared Preferences (settings) ────────────────────────────────────

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> clearAll() => _prefs.clear();
}
''';
