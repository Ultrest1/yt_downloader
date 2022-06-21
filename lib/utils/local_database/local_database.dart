import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:yt_downloader/utils/local_database/user_db.dart';

///First Create,
///Then read to model,
///then modify it,
///then use adddata
class LocalDatabase {
  static LocalDatabase? _instace;
  static LocalDatabase? get instance {
    _instace ??= LocalDatabase._init();
    return _instace;
  }

  File? _databaseFile;
  String? _directoryPath;
  UserDB? _userDB; //!null model
  final dbName = "local_db.json";
  LocalDatabase._init() {
    initDB();
  }

  Future<void> initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    _directoryPath = dir.path;
    log("dir: $_directoryPath");
    _databaseFile = File("$_directoryPath/$dbName");
    try {
      _userDB = UserDB.fromJson(_databaseFile?.readAsStringSync() ?? "");
      print("Reading succesful");
    } on FileSystemException catch (e) {
      if (e.message == "Cannot open file") {
        _userDB = UserDB(
          name: "Unknown",
          description: "Unknown",
          history: [],
          isPermissionGranted: false,
        );
        _databaseFile?.writeAsStringSync(_userDB?.toJson() ?? "");
        print("Creating succesful");
      }
    }
  }

  UserDB? readFile() =>
      UserDB.fromJson(_databaseFile?.readAsStringSync() ?? "");

  void writeData() => _databaseFile?.writeAsStringSync(_userDB?.toJson() ?? "");

  File? get getDatabaseFile => _databaseFile;
  UserDB? get getDBModel => _userDB;
}
