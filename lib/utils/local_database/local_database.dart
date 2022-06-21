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
  UserDB? _userDB;
  final dbName = "local_db.json";
  LocalDatabase._init() {
    checkCreatedBefore();
  }
  Future<void> _createDir() async {
    final dir = await getApplicationDocumentsDirectory();
    _directoryPath = dir.path;
    _databaseFile = createFile();
  }

  File createFile() {
    final localUserDB = UserDB(
        name: "Unkown",
        description: "Unkown",
        history: [],
        isPermissionGranted: false);
    final file = File("$_directoryPath/$dbName");
    file.writeAsStringSync(localUserDB.toJson());
    return file;
  }

  UserDB? readFile() =>
      UserDB.fromJson(_databaseFile?.readAsStringSync() ?? "");

  void addData(UserDB? model) =>
      _databaseFile?.writeAsStringSync(model?.toJson() ?? "");

  File? get getDatabaseFile => _databaseFile;
  UserDB? get getDBModel => _userDB;

  Future<bool?> checkCreatedBefore() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$dbName");
    final content = file.readAsStringSync();
    if (content == "") {
      //create
      _databaseFile = createFile();
      // end function here
    }
    //pull all data from existed file
    _databaseFile = file;
    _directoryPath = dir.path;
    final model = readFile();
    if (model == null) {
      if (model?.name == null) {
        //database yoksa
        _userDB = UserDB(
            name: "Unknown",
            description: "Unknown",
            history: [],
            isPermissionGranted: false);
        return false;
      }
    } else {
      //db varsa

      _databaseFile = File("$_directoryPath/$dbName");

      return true;
    }
  }
}

///check is db file created before
///if created pull all data from there
///otherwise create one
///
///
