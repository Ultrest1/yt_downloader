import 'package:flutter/material.dart';
import 'package:yt_downloader/product/video_preview.dart';

import '../product/searched_handler.dart';

class DownloadedView extends StatefulWidget {
  DownloadedView({Key? key}) : super(key: key);

  @override
  State<DownloadedView> createState() => _DownloadedViewState();
}

class _DownloadedViewState extends State<DownloadedView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Dismissible(
        key: ValueKey(SearchedHolder.instance.getDownloadedVideoList[index].title),
        child: VideoPreview(
          isDownloaded: false,
          isStarted: false,
          onTap: () {},
          video: SearchedHolder.instance.getDownloadedVideoList[index],
        ),
      ),
      itemCount: SearchedHolder.instance.getDownloadedVideoList.length,
    );
  }
}
