import 'package:flutter/material.dart';

import 'download_video_view.dart';
import 'downloaded_view.dart';

class TabView extends StatefulWidget {
  TabView({Key? key}) : super(key: key);

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.download)),
            Tab(icon: Icon(Icons.download_done)),
          ]),
        ),
        body: TabBarView(children: [
          DownloadVideo(),
          DownloadedView(),
        ]),
      ),
    );
  }
}
