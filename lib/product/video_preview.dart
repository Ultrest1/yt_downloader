import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoPreview extends StatelessWidget {
  VideoPreview(
      {Key? key,
      required this.video,
      required this.onTap,
      this.progress,
      required this.isStarted,
      this.isDownloaded = false})
      : super(key: key);
  final Video? video;
  VoidCallback? onTap;
  bool isDownloaded;
  Map<int, int>? progress;
  bool isStarted;

  final download = "Download";

  @override
  Widget build(BuildContext context) {
    if (video == null) {
      return const Center(child: Text("Null video"));
    } else {
      return isDownloaded == false
          ? Padding(
              padding: EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [thumbnail(), videoDetails(context)],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(flex: 5, child: videoThumbnail()),
                    Expanded(
                      flex: 20,
                      child: Text(
                        video?.title ?? "null title",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    )
                  ],
                ),
              ),
            );
    }
  }

  Expanded thumbnail() {
    return Expanded(
        child: Column(
      children: [
        videoThumbnail(),
        ElevatedButton(onPressed: onTap, child: Text(download)),
        isStarted == false
            ? SizedBox()
            : CircularProgressIndicator.adaptive(
                value: (progress?.entries.first.key ?? 0) / (progress?.entries.first.value ?? 0),
              )
      ],
    ));
  }

  Padding videoThumbnail() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(video?.thumbnails.highResUrl ?? "")));
  }

  Expanded videoDetails(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video?.title ?? "null title", style: Theme.of(context).textTheme.headline4),
          const Divider(),
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
                physics: video!.description.length > 50
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: SelectableText(video?.description ?? "null description",
                    style: Theme.of(context).textTheme.caption)),
          )
        ],
      ),
    );
  }
}
