import 'package:flutter/material.dart';

import 'video_model.dart';

class VideoPreview extends StatelessWidget {
  VideoPreview({
    Key? key,
    required this.video,
    required this.onTap,
  }) : super(key: key);
  final BaseVideoModel? video;
  VoidCallback? onTap;

  final download = "Download";

  @override
  Widget build(BuildContext context) {
    if (video == null) {
      return const Center(child: Text("Null video"));
    } else {
      switch (video?.isDownloaded) {
        case true:
          return downloaded(context);
        case false:
          return notDownloaded(context);
        default:
          return const Center(child: Text("Hello"));
      }
    }
  }

  Padding downloaded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Expanded(flex: 5, child: videoThumbnail()),
            Expanded(
              flex: 20,
              child: Text(
                video?.video?.title ?? "null title",
                style: Theme.of(context).textTheme.headline4,
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding notDownloaded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [thumbnail(), videoDetails(context)],
        ),
      ),
    );
  }

  Expanded thumbnail() {
    return Expanded(
        child: Column(
      children: [
        videoThumbnail(),
        Text("Author: ${video?.video?.author}"),
        Text("View count: ${video?.video?.engagement.viewCount}"),
        Text("Duration: ${video?.video?.duration?.inMinutes}:${video?.video?.duration?.inSeconds}"),
        ElevatedButton(onPressed: onTap, child: Text(download)),
        const Divider(),
        video?.progress == null
            ? SizedBox()
            : LinearProgressIndicator(
                value: (video?.progress ?? 1) / 10,
              )
        // progress == ""
        //     ? const SizedBox()
        //     : CircularProgressIndicator(
        //         value: double.parse(progress ?? "1"),
        //       )
      ],
    ));
  }

  Padding videoThumbnail() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(video?.video?.thumbnails.highResUrl ?? "")));
  }

  Expanded videoDetails(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video?.video?.title ?? "null title", style: Theme.of(context).textTheme.headline4),
          const Divider(),
          SizedBox(
            height: (video?.video!.description.length ?? 10) > 50 ? 250 : 100,
            child: SingleChildScrollView(
                physics: (video?.video!.description.length ?? 10) > 50
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: SelectableText(video?.video?.description ?? "null description",
                    style: Theme.of(context).textTheme.caption)),
          )
        ],
      ),
    );
  }
}
