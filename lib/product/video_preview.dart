// import 'package:flutter/material.dart';

// import 'base_video_model.dart';

// // ignore: must_be_immutable
// class VideoPreview extends StatelessWidget {
//   VideoPreview({
//     Key? key,
//     required this.video,
//     required this.onTap,
//   }) : super(key: key);
//   final BaseVideoModel? video;
//   VoidCallback? onTap;

//   final download = "Download";
//   final nullVideo = "Null video";
//   final nullTitle = "Null title";
//   final author = "Author: ";
//   final duration = "Duration: ";
//   final viewCount = "View count: ";

//   @override
//   Widget build(BuildContext context) {
//     if (video == null) {
//       return Center(child: Text(nullVideo));
//     } else {
//       switch (video?.isDownloaded) {
//         case true:
//           return downloaded(context);
//         case false:
//           return notDownloaded(context);
//         default:
//           return const Center(child: Text("Hello"));
//       }
//     }
//   }

//   Padding downloaded(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Row(
//           children: [
//             Expanded(flex: 5, child: videoThumbnail()),
//             const VerticalDivider(thickness: 10),
//             Expanded(
//               flex: 20,
//               child: Text(
//                 video?.videoRef?.title ?? nullTitle,
//                 style: Theme.of(context).textTheme.headline4,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Padding notDownloaded(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         elevation: 10,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [thumbnail(), videoDetails(context)],
//         ),
//       ),
//     );
//   }

//   Expanded thumbnail() {
//     return Expanded(
//         child: Column(
//       children: [
//         videoThumbnail(),
//         Text("$author ${video?.videoRef?.author}"),
//         Text("$viewCount ${video?.videoRef?.engagement.viewCount}"),
//         Text(
//             "$duration ${video?.videoRef?.duration?.inMinutes}:${video?.videoRef?.duration?.inSeconds}"),
//         const Divider(),
//         video?.progress == null
//             ? SizedBox()
//             : LinearProgressIndicator(
//                 minHeight: 10,
//                 value: (video?.progress ?? 1),
//               )
//       ],
//     ));
//   }

//   Padding videoThumbnail() {
//     return Padding(
//         padding: const EdgeInsets.all(20),
//         child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child:
//                 Image.network(video?.videoRef?.thumbnails.highResUrl ?? "")));
//   }

//   Expanded videoDetails(BuildContext context) {
//     return Expanded(
//       flex: 2,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(video?.videoRef?.title ?? "null title",
//               style: Theme.of(context).textTheme.headline4),
//           const Divider(),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Expanded(
//                 flex: 5,
//                 child: SizedBox(
//                   height: (video?.videoRef!.description.length ?? 10) > 50
//                       ? 250
//                       : 100,
//                   child: SingleChildScrollView(
//                       physics: (video?.videoRef!.description.length ?? 10) > 50
//                           ? const AlwaysScrollableScrollPhysics()
//                           : const NeverScrollableScrollPhysics(),
//                       child: SelectableText(
//                           video?.videoRef?.description ?? "null description",
//                           style: Theme.of(context).textTheme.caption)),
//                 ),
//               ),
//               Expanded(child: Icon(Icons.done))
//             ],
//           ),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButton<String>(items: [
//                 DropdownMenuItem(child: Text("720")),
//               ], onChanged: (val) {}),
//               ElevatedButton(onPressed: onTap, child: Text(download)),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:yt_downloader/product/base_video_model.dart';

import 'searched_handler.dart';

class VideoCard extends StatelessWidget {
  VideoCard({Key? key, required this.videoModel, required this.downloadVidFunc})
      : super(key: key);
  BaseVideoModel videoModel;
  void Function()? downloadVidFunc;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                                      videoModel.dropdownValue =
                                          p0 as AvailableOption;
                                    },
                                  )
                                : const SizedBox(),
                            videoModel.isDownloaded != null
                                ? videoModel.isDownloaded
                                    ? ElevatedButton(
                                        onPressed: () {}, child: Text(openText))
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
            ),
            videoModel.progress != null
                ? Row(
                    children: [
                      Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                                value: videoModel.progress),
                          )),
                      Expanded(
                          child: Text(
                              "${((videoModel.progress ?? 0) * 100).toStringAsFixed(1)}%"))
                    ],
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
