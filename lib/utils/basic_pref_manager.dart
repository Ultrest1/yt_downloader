import 'package:shared_preferences/shared_preferences.dart';
import 'package:yt_downloader/utils/user_pref.dart';

class BasicPrefManager {
  static BasicPrefManager? _instace;
  static BasicPrefManager? get instance {
    _instace;
    return _instace;
  }

  late final SharedPreferences _sharedPreferences;

  BasicPrefManager._init();

  initPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<bool> writeBoolean(UserPrefs userPrefs, bool value) async {
    return await _sharedPreferences.setBool(userPrefs.name, value);
  }

  bool getBoolean(UserPrefs userPrefs) {
    final stat = _sharedPreferences.getBool(userPrefs.name);
    if (stat == null) return false;
    return stat;
  }

  Future<bool> writeVideoLinks(List<String> linkList,
      {String key = "videoLinks"}) async {
    return await _sharedPreferences.setStringList(key, linkList);
  }

  List<String>? getVideoLinks({String key = "videoLinks"}) =>
      _sharedPreferences.getStringList(key);
}
