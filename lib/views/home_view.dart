// ignore_for_file: prefer_is_empty

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yt_downloader/utils/local_database/local_database.dart';
import '../product/searched_handler.dart';

import '../product/base_video_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final textController = TextEditingController();
  final textFieldNode = FocusNode();
  final String searchedBeforeURL = "";
  final String hintText = "search.. www.youtube.com";
  final String noVideo = "No video yet";
  final String nullTitle = "Null title";
  final String nullAuthor = "null author";
  final String openText = "Open";
  final String downloadText = "Download";
  final String nullDescrip = "null description";
  final String ytLink = "www.youtube.com";
  late final LocalDatabase? dbInstance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          onSubmitted: (value) => searchYTVideo(textController.text, context),
          controller: textController,
          decoration: InputDecoration(
              hintText: hintText, border: const UnderlineInputBorder()),
        ),
        actions: [
          IconButton(
              onPressed: () => searchYTVideo(textController.text, context),
              icon: const Icon(Icons.search))
        ],
      ),
      body: Column(
        mainAxisAlignment:
            VideoDownloadHsistory.instance.getVideoList.length == 0
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          // inputArea(),
          VideoDownloadHsistory.instance.getVideoList.length == 0
              ? SizedBox()
              : const Divider(),
          build2List(),
        ],
      ),
    );
  }

  Widget build2List() {
    if (VideoDownloadHsistory.instance.getVideoList.length == 0) {
      return Center(child: Text(noVideo));
    } else {
      return Expanded(
          child: ListView.builder(
        itemBuilder: (context, index) {
          final video = VideoDownloadHsistory.instance.getVideoList[index];
          return Card(
            child: Dismissible(
                onDismissed: (direction) {
                  VideoDownloadHsistory.instance.getVideoList.removeAt(index);
                  setState(() {});
                },
                key: ValueKey("video: ${video?.videoRef?.title}"),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 5,
                            child: Image.network(
                                video?.videoRef?.thumbnails.mediumResUrl ??
                                    "")),
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(video?.videoRef?.title ?? nullTitle,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.clip),
                                Text(
                                  video?.videoRef?.author ?? nullAuthor,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    video != null
                                        ? video.toDropDown(
                                            onChanged: (p0) {
                                              video.dropdownValue =
                                                  p0 as AvailableOption;

                                              setState(() {});
                                            },
                                          )
                                        : const SizedBox(),
                                    video?.isDownloaded != null
                                        ? video!.isDownloaded
                                            ? ElevatedButton(
                                                onPressed: () {},
                                                child: Text(openText))
                                            : ElevatedButton(
                                                onPressed: () {
                                                  downloadvid(
                                                      VideoDownloadHsistory
                                                          .instance
                                                          .getVideoList[index]);
                                                  setState(() {
                                                    //todo asdasdas
                                                  });
                                                },
                                                child: Text(downloadText))
                                        : ElevatedButton(
                                            onPressed: () {
                                              downloadvid(VideoDownloadHsistory
                                                  .instance
                                                  .getVideoList[index]);
                                              setState(() {});
                                            },
                                            child: Text(downloadText))
                                  ],
                                )
                              ],
                            )),
                      ],
                    ),
                    video?.progress != null
                        ? Row(
                            children: [
                              Expanded(
                                  flex: 9,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LinearProgressIndicator(
                                        value: video?.progress),
                                  )),
                              Expanded(
                                  child: Text(
                                      "${((video?.progress ?? 0) * 100).toStringAsFixed(1)}%"))
                            ],
                          )
                        : const SizedBox()
                  ],
                )),
          );
        },
        itemCount: VideoDownloadHsistory.instance.getVideoList.length,
      ));
    }
  }

  Future<ListTile> listtile(int index) async {
    return ListTile(
      leading: Image.network(VideoDownloadHsistory
              .instance.getVideoList[index]?.videoRef?.thumbnails.highResUrl ??
          ""),
      title: Text(
          VideoDownloadHsistory.instance.getVideoList[index]?.videoRef?.title ??
              nullTitle),
      subtitle: Text(VideoDownloadHsistory
              .instance.getVideoList[index]?.videoRef?.description ??
          nullDescrip),
      trailing:
          IconButton(onPressed: () async {}, icon: const Icon(Icons.download)),
    );
  }

  Row inputArea() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                onSubmitted: (value) =>
                    searchYTVideo(textController.text, context),
                controller: textController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withAlpha(20),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    hintText: ytLink)),
          ),
        ),
        IconButton(
            onPressed: () => searchYTVideo(textController.text, context),
            icon: const Icon(Icons.search))
      ],
    );
  }

  Future<void> downloadvid(BaseVideoModel? videoModel) async {
    final dio = Dio();
    final isOkay = await videoModel?.prepareToDownload();
    videoModel?.generatePathFile();
    if (isOkay == false) return;

    await dio.download(
      videoModel?.dropdownValue?.url?.toString() ?? "",
      "${videoModel?.rootPath}\\${videoModel?.videoFileName}",
      onReceiveProgress: (count, total) {
        setState(() {
          videoModel?.progress = (((count / total) * 10) / 10);
        });
        if (videoModel?.progress == 1) {
          videoModel?.isDownloaded = true;
        }
      },
    );

    if (videoModel?.videoRef?.description != null) {
      createDescription(videoModel);
    }

    if (videoModel == null) return;
    setState(() {});
  }

  void createDescription(BaseVideoModel? videoModel) {
    final descriptionFile = File("${videoModel?.rootPath}\\description.txt");
    descriptionFile.writeAsStringSync(videoModel?.videoRef?.description ?? "");
    log("description file created succesfully");
  }

  void searchYTVideo(String url, BuildContext context) async {
    final newVideo = BaseVideoModel(url);
    await newVideo.makeSearch(url, context);
    await newVideo.prepareToDownload();
    textController.clear();
    textFieldNode.unfocus();
    setState(() {});
  }

  void initDatabase() {
    dbInstance = LocalDatabase.instance;
  }

  addDataToDB() {}
  //todo crud foor database
}
