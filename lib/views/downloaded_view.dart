import 'package:flutter/material.dart';

import '../product/searched_handler.dart';
import '../product/video_preview.dart';

class DownloadedView extends StatefulWidget {
  const DownloadedView({Key? key}) : super(key: key);

  @override
  State<DownloadedView> createState() => _DownloadedViewState();
}

class _DownloadedViewState extends State<DownloadedView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Dismissible(
        key: ValueKey(VideoBucket.instance.getDownloadedVideoList[index]?.videoRef?.title),
        child: VideoPreview(
          onTap: () {},
          video: VideoBucket.instance.getDownloadedVideoList[index],
        ),
      ),
      itemCount: VideoBucket.instance.getDownloadedVideoList.length,
    );
  }
}
