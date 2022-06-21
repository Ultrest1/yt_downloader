import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_downloader/utils/local_database/local_database.dart';
import 'package:yt_downloader/views/home_view.dart';
import 'product/searched_handler.dart';

Future<void> main() async {
  VideoDownloadHsistory.instance;

  // BasicPrefManager.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await checkIsDBCreatedOnce();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Youtube Downloader',
      home: SafeArea(child: HomeView()),
    );
  }
}

Future<void> checkPermissions() async {
  if (await Permission.storage.isDenied) {
    final status = Permission.storage.request();
    final writePer = Permission.manageExternalStorage.request();
    final model = LocalDatabase.instance?.readFile();
    model?.isPermissionGranted = true;
    LocalDatabase.instance?.addData(model);
  }
}

Future<void> checkIsDBCreatedOnce() async {
  await Future.delayed(Duration(milliseconds: 500));

  final model = LocalDatabase.instance?.readFile();
  if (model == null) return;
  if (model.isPermissionGranted ?? false) {
    if (Platform.isAndroid || Platform.isIOS) {
      checkPermissions();
    }
  }
}
