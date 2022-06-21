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

  late final File _database;
  late final String _directoryPath;
  LocalDatabase._init() {
    _createDir();
  }
  File createFile() {
    final localUserDB = UserDB(
        name: "Unkown",
        description: "Unkown",
        history: [],
        isPermissionGranted: false);
    final file = File("$_directoryPath/local_db.json");
    file.writeAsStringSync(localUserDB.toJson());
    return file;
  }

  Future<void> _createDir() async {
    final dir = await getApplicationDocumentsDirectory();
    _directoryPath = dir.path;
    _database = createFile();
  }

  UserDB? readFile() => UserDB.fromJson(_database.readAsStringSync());

  void addData(UserDB? model) =>
      _database.writeAsStringSync(model?.toJson() ?? "");

  File get getDatabaseFile => _database;
}
