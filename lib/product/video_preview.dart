// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:yt_downloader/product/base_video_model.dart';

class VideoCard extends StatelessWidget {
  VideoCard({
    Key? key,
    required this.videoModel,
    required this.downloadVidFunc,
    required this.dropdown,
    required this.scrollController,
    required this.openFunc,
    required this.downloadFunc,
    this.isOpenedFunc,
    required this.isOpened,
  }) : super(key: key);
  BaseVideoModel videoModel;
  void Function() downloadVidFunc;
  void Function() openFunc;
  void Function(BaseVideoModel model, String url) downloadFunc;
  void Function(AvailableOption?)? dropdown;
  final VoidCallback? isOpenedFunc;
  bool isOpened;
  // void Function()? onPressed;
  final ScrollController scrollController;
  final String searchedBeforeURL = "";
  final String hintText = "search.. www.youtube.com";
  final String noVideo = "No video yet";
  final String nullTitle = "Null title";
  final String nullAuthor = "null author";
  final String openText = "Open";
  final String downloadText = "Download";
  final String nullDescrip = "null description";
  final String ytLink = "www.youtube.com";
  final String optionsText = "Quality Options";

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
        // videoContent(context),
        image(context),
        const Divider(),
        titleText(context),
        authorText(context),
        const Divider(),
        degisik(context),
        indicator(context)
      ],
    );
  }

  //https://www.youtube.com/watch?v=iLyy_J0wyTU

  Widget degisik(BuildContext context) {
    return ListView(
        controller: scrollController,
        shrinkWrap: true,
        children: isOpened ? _getStreamList() : [_getStreamList().first]);
  }

  List<ListTile> _getStreamList() {
    List<ListTile> list = [];
    int i = 0;

    if (videoModel.manifest == null) return [];
    if (videoModel.manifest?.video == null) return [];
    for (var element in videoModel.manifest!.video) {
      list.add(ListTile(
        enableFeedback: true,
        visualDensity: VisualDensity.compact,
        leading: Text(element.qualityLabel),
        title: Text(
            "${element.codec.mimeType} | ${element.framerate.framesPerSecond} fps"),
        subtitle: Text(element.videoCodec),
        onTap: () {
          if (videoModel.status != VideoStatus.downloading) {
            downloadFunc(videoModel, element.url.toString());
          }
        },
        trailing: Text("${element.size.totalMegaBytes.toStringAsFixed(2)} mb"),
      ));
    }
    list.insert(
        0,
        ListTile(
          title: Text(optionsText),
          trailing: IconButton(
              onPressed: isOpenedFunc,
              icon: isOpened
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down)),
        ));
    return list;
  }

  Widget image(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        videoModel.videoRef?.thumbnails.highResUrl ?? "",
        fit: BoxFit.fitWidth,
      ),
    );
  }

  // Widget downloadBTN(BuildContext context) {
  //   if (videoModel != null) {
  //     if (videoModel.isDownloaded) {
  //       return ElevatedButton(
  //         onPressed: openFunc,
  //         style: ButtonStyle(
  //             shape: MaterialStateProperty.all(const StadiumBorder())),
  //         child: Text(openText),
  //       );
  //     } else {
  //       return ElevatedButton(
  //           onPressed: downloadVidFunc,
  //           style: ButtonStyle(
  //               shape: MaterialStateProperty.all(const StadiumBorder())),
  //           child: Text(downloadText));
  //     }
  //   } else {
  //     return ElevatedButton(
  //         onPressed: downloadVidFunc,
  //         style: ButtonStyle(
  //             shape: MaterialStateProperty.all(const StadiumBorder())),
  //         child: Text(downloadText));
  //   }
  // }

  Widget indicator(BuildContext context) {
    if (videoModel.progress != null) {
      return indicators();
    } else if (videoModel.status == VideoStatus.done) {
      return Text("Done");
    }
    return const SizedBox();
  }

  // Widget videoContent(BuildContext context) {
  //   return Column(
  //     children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(15),
  //         child: Image.network(
  //           videoModel.videoRef?.thumbnails.mediumResUrl ?? "",
  //           fit: BoxFit.fitWidth,
  //         ),
  //       ),
  //       const Divider(),
  //       Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             titleText(context),
  //             authorText(context),
  //             videoModel != null
  //                 ? Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       videoModel.toDropDown(
  //                         onChanged: dropdown,
  //                       ),
  //                       downloadBTN(context)
  //                     ],
  //                   )
  //                 : const SizedBox(),
  //             // Container(
  //             //   child: Icon(Icons.add),
  //             // )
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
