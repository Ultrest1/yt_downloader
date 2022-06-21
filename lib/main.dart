import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_downloader/utils/local_database/local_database.dart';
import 'package:yt_downloader/utils/user_pref.dart';
import 'package:yt_downloader/views/home_view.dart';
import 'product/searched_handler.dart';
import 'utils/basic_pref_manager.dart';

void main() {
  VideoDownloadHsistory.instance;
  // BasicPrefManager.instance;
  LocalDatabase.instance;
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    checkPermissions();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: SafeArea(child: HomeView()),
    );
  }
}

Future<void> checkPermissions() async {
  final db = LocalDatabase.instance;
  if (await Permission.storage.isDenied) {
    final status = Permission.storage.request();
    final writePer = Permission.manageExternalStorage.request();
    final model = db?.readFile();
    model?.isPermissionGranted = true;
    db?.addData(model);
  }
}
