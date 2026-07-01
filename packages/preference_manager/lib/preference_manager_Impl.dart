part of 'shared_pref.dart';

class AppPreferenceManager implements PreferenceManager {
  final SharedPreferences? _pref;

  AppPreferenceManager(this._pref);

  @override
  Future<bool> removePreference(String key) {
    try {
      return _pref?.remove(key) ?? Future.value(false);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<bool> saveString(String key, String value) {
    try {
      return _pref?.setString(key, value) ?? Future.value(false);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  String? getStringOrNull(String key) {
    try {
      return _pref?.getString(key);
    } catch (e) {
      return null;
    }
  }

  @override
  String getStringOrEmpty(String key) {
    try {
      return _pref?.getString(key) ?? "";
    } catch (e) {
      return "";
    }
  }

  @override
  Future<bool> saveInt(String key, int value) {
    var response = _pref?.setInt(key, value) ?? Future.value(false);
    return response;
  }

  @override
  int getInt(String key) {
    try {
      var value = _pref?.getInt(key);
      if (value != null) {
        return value;
      } else {
        throw Exception("Preference not initialized");
      }
    } catch (e) {
      debugPrint(e.toString());
      return -1;
    }
  }

  @override
  Future<bool> saveDouble(String key, double value) {
    try {
      return _pref?.setDouble(key, value) ?? Future.value(false);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  double getDouble(String key) {
    try {
      var value = _pref?.getDouble(key);
      if (value != null) {
        return value;
      } else {
        throw Exception("Preference not initialized");
      }
    } catch (e) {
      debugPrint(e.toString());
      return -1.0;
    }
  }

  @override
  Future<bool> saveBool(String key, bool value) {
    try {
      return _pref?.setBool(key, value) ?? Future.value(false);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _pref?.getBool(key) ?? defaultValue;
    } catch (e) {
      debugPrint(e.toString());
      return defaultValue;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _pref?.clear() ?? false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
