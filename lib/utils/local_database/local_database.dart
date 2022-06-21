import 'dart:io';
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
  late final String databasePath;
  LocalDatabase._init() {
    _database = createFile();
    databasePath = _database.path;
  }
  File createFile() {
    final model = UserDB(name: "Unkown", description: "Unkown", url: []);
    final file = File("database.json");
    file.writeAsStringSync(model.toJson());
    return file;
  }

  UserDB readFile() => UserDB.fromJson(_database.readAsStringSync());

  void addData(UserDB? model) =>
      _database.writeAsStringSync(model?.toJson() ?? "");

  File get getDatabaseFile => _database;
}
