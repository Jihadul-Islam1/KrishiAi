import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] that encodes JSON for lists/maps.
/// All persistent app data flows through this service so it can later be
/// swapped for an encrypted local DB without touching repositories.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  Future<void> writeJson(String key, Object value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Object? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool readBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
