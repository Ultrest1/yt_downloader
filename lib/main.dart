import 'package:flutter/material.dart';
import 'package:yt_downloader/product/searched_handler.dart';
import 'views/home_view.dart';

void main() {
  VideoDownloadHsistory.instance;
  WidgetsFlutterBinding.ensureInitialized();
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
