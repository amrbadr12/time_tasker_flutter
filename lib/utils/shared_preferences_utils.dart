import 'package:shared_preferences/shared_preferences.dart';

class SharedPerferencesUtils {
  SharedPreferences _sharedPreferences;

  SharedPerferencesUtils(SharedPreferences preferences) {
    this._sharedPreferences = preferences;
  }

  void saveBoolToSharedPreferences(String key, bool data) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setBool(key, data);
    }
  }

  bool getBoolFromSharedPreferences(String key) {
    return _sharedPreferences.getBool(key) ?? false;
  }

  void saveIntToSharedPreferences(String key, int data) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setInt(key, data);
    }
  }

  int getIntFromSharedPreferences(String key) {
    return _sharedPreferences.getInt(key) ?? 0;
  }

  void saveStringToSharedPreferences(String key, String data) {
    if (_sharedPreferences != null) {
      _sharedPreferences.setString(key, data);
    }
  }

  String getStringFromSharedPreferences(String key) {
    return _sharedPreferences.getString(key);
  }
}
