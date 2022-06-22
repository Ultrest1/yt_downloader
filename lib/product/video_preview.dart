// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:yt_downloader/product/base_video_model.dart';

import 'searched_handler.dart';

class VideoCard extends StatelessWidget {
  VideoCard(
      {Key? key,
      required this.videoModel,
      required this.downloadVidFunc,
      required this.dropdown,
      required this.openFunc})
      : super(key: key);
  BaseVideoModel videoModel;
  void Function()? downloadVidFunc;
  void Function()? openFunc;
  void Function(AvailableOption?)? dropdown;
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: baseColumn(context),
        ),
      ),
    );
  }

  Column baseColumn(BuildContext context) {
    return Column(
      children: [
        videoContent(context),
        indicator(context),
      ],
    );
  }

  Widget downloadBTN(BuildContext context) {
    if (videoModel != null) {
      if (videoModel.isDownloaded) {
        return ElevatedButton(
          onPressed: openFunc,
          style: ButtonStyle(
              shape: MaterialStateProperty.all(const StadiumBorder())),
          child: Text(openText),
        );
      } else {
        return ElevatedButton(
            onPressed: downloadVidFunc,
            style: ButtonStyle(
                shape: MaterialStateProperty.all(const StadiumBorder())),
            child: Text(downloadText));
      }
    } else {
      return ElevatedButton(
          onPressed: downloadVidFunc,
          style: ButtonStyle(
              shape: MaterialStateProperty.all(const StadiumBorder())),
          child: Text(downloadText));
    }
  }

  Widget indicator(BuildContext context) {
    if (videoModel.progress != null) {
      return indicators();
    }
    return const SizedBox();
  }

  Widget videoContent(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            videoModel.videoRef?.thumbnails.mediumResUrl ?? "",
            fit: BoxFit.fitWidth,
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText(context),
              authorText(context),
              videoModel != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        videoModel.toDropDown(
                          onChanged: dropdown,
                        ),
                        downloadBTN(context)
                      ],
                    )
                  : const SizedBox(),
              // Container(
              //   child: Icon(Icons.add),
              // )
            ],
          ),
        ),
      ],
    );
  }

  Text titleText(BuildContext context) {
    return Text(videoModel.videoRef?.title ?? nullTitle,
        style: Theme.of(context).textTheme.headline6,
        maxLines: 2,
        overflow: TextOverflow.ellipsis);
  }

  Text authorText(BuildContext context) {
    return Text(
      videoModel.videoRef?.author ?? nullAuthor,
      style: Theme.of(context).textTheme.bodySmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Row indicators() {
    return Row(
      children: [
        Expanded(
            flex: 6,
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
