import 'package:flutter/material.dart';
import 'package:yt_downloader/product/searched_handler.dart';
import 'package:yt_downloader/views/tab_bar.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  SearchedHolder.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: TabView(),
    );
  }
}
