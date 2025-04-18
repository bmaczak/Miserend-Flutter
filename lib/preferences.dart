import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  static final String _databaseLastUpdated = "DATABASE_LAST_UPDATED";

  static final String _savedDatabaseVersion = "SAVED_DATABASE_VERSION";

  static Future<void> setDatabaseVersion(int version) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_savedDatabaseVersion, version);
  }

  static Future<int?> getDatabaseVersion() async
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_savedDatabaseVersion);
  }

  static Future<void> setDatabaseLastUpdated(int timeMillis) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_databaseLastUpdated, timeMillis);
  }

  static Future<int?> getDatabaseLastUpdated() async
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_databaseLastUpdated);
  }
}