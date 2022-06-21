// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:yt_downloader/product/base_video_model.dart';

import 'searched_handler.dart';

class VideoCard extends StatelessWidget {
  VideoCard(
      {Key? key,
      required this.videoModel,
      required this.downloadVidFunc,
      required this.openFunc})
      : super(key: key);
  BaseVideoModel videoModel;
  void Function()? downloadVidFunc;
  void Function()? openFunc;
  // void Function()? onPressed;
  final String searchedBeforeURL = "";
  final String hintText = "search.. www.youtube.com";
  final String noVideo = "No video yet";
  final String nullTitle = "Null title";
  final String nullAuthor = "null author";
  final String openText = "Open";
  final String downloadText = "Download";
  final String nullDescrip = "null description";
  final String ytLink = "www.youtube.com";

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Dismissible(
        key: ValueKey("video: ${videoModel.videoRef?.title}"),
        onDismissed: (direction) {
          VideoDownloadHsistory.instance.removeVideoWithVideo(videoModel);
        },
        child: baseColumn(context),
      ),
    );
  }

  Column baseColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        videoContent(context),
        videoModel.progress != null ? indicators() : const SizedBox()
      ],
    );
  }

  Row videoContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 5,
            child: Image.network(
                videoModel.videoRef?.thumbnails.mediumResUrl ?? "")),
        Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(videoModel.videoRef?.title ?? nullTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 3,
                    overflow: TextOverflow.clip),
                Text(
                  videoModel.videoRef?.author ?? nullAuthor,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    videoModel != null
                        ? videoModel.toDropDown(
                            onChanged: (p0) {
                              videoModel.dropdownValue = p0 as AvailableOption;
                            },
                          )
                        : const SizedBox(),
                    videoModel.isDownloaded != null
                        ? videoModel.isDownloaded
                            ? ElevatedButton(
                                onPressed: openFunc, child: Text(openText))
                            : ElevatedButton(
                                onPressed: downloadVidFunc,
                                child: Text(downloadText))
                        : ElevatedButton(
                            onPressed: downloadVidFunc,
                            child: Text(downloadText))
                  ],
                )
              ],
            )),
      ],
    );
  }

  Row indicators() {
    return Row(
      children: [
        Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(value: videoModel.progress),
            )),
        Expanded(
            child: Text(
                "${((videoModel.progress ?? 0) * 100).toStringAsFixed(1)}%"))
      ],
    );
  }
}
