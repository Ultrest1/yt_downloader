// ignore_for_file: prefer_is_empty

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_downloader/contants/contants.dart';
import 'package:yt_downloader/product/video_preview.dart';
import 'package:yt_downloader/utils/local_database/local_database.dart';

import '../product/base_video_model.dart';
import '../product/searched_handler.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final textController = TextEditingController();
  final textFieldNode = FocusNode();

  //deneme

  bool isOpened = false;
  late final LocalDatabase? instanceDB;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    initDB();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldNode.dispose();
    instanceDB?.writeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: GestureDetector(
        onTap: () {
          textFieldNode.unfocus();
        },
        child: Column(
          mainAxisAlignment:
              VideoDownloadHsistory.instance.getVideoList.length == 0
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children: [
            // inputArea(),
            VideoDownloadHsistory.instance.getVideoList.length == 0
                ? const SizedBox()
                : const Divider(),
            buildList(),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: TextField(
        onSubmitted: (value) => searchYTVideo(textController.text, context),
        controller: textController,
        cursorColor: Colors.red,
        cursorHeight: 20,
        decoration: InputDecoration(
            hintText: contants.hintText, border: const UnderlineInputBorder()),
      ),
      actions: [
        IconButton(
            onPressed: () => searchYTVideo(textController.text, context),
            icon: const Icon(Icons.search))
      ],
    );
  }

  Widget buildList() {
    if (VideoDownloadHsistory.instance.getVideoList.length == 0) {
      return Center(child: Text(contants.noVideo));
    } else {
      return Expanded(
          child: ListView.builder(
        itemBuilder: (context, index) {
          final video = VideoDownloadHsistory.instance.getVideoList.reversed
              .toList()[index];
          return Dismissible(
            key: ValueKey("video: ${video?.videoRef?.title}"),
            onDismissed: (direction) {
              VideoDownloadHsistory.instance.removeVideoWithVideo(video!);
              setState(() {});
            },
            child: videoCard(index, video, context),
          );
        },
        itemCount: VideoDownloadHsistory.instance.getVideoList.length,
      ));
    }
  }

  VideoCard videoCard(int index, BaseVideoModel? video, BuildContext context) {
    return VideoCard(
      isOpened: isOpened,
      scrollController: scrollController,
      videoModel: video ?? BaseVideoModel(""),
      downloadVidFunc: () async {
        // await downloadvid(VideoDownloadHsistory.instance.getVideoList[index]);
        // setState(() {});
      },
      dropdown: (p) {
        video?.dropdownValue = p;
        setState(() {});
      },
      openFunc: () {
        openFile(video);
      },
      isOpenedFunc: () {
        isOpened = !isOpened;
        setState(() {});
      },
      downloadFunc: downloadVid,
    );
  }

  Row inputArea() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                focusNode: textFieldNode,
                cursorColor: Colors.red,
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
                    hintText: contants.ytLink)),
          ),
        ),
        IconButton(
            onPressed: () => searchYTVideo(textController.text, context),
            icon: const Icon(Icons.search))
      ],
    );
  }

  Future<void> downloadVid(BaseVideoModel? videoModel, String url) async {
    await checkPermission();
    if (videoModel?.status == VideoStatus.done &&
        videoModel?.status == VideoStatus.waiting) {
      videoModel?.status == VideoStatus.downloading;
    }
    final dio = Dio();
    final isOkay = await videoModel?.prepareToDownload();
    await videoModel?.generatePathFile();
    if (isOkay == false) return;

    videoModel?.status = VideoStatus.downloading;
    try {
      await dio.download(
        url,
        "${videoModel?.rootPath}/${videoModel?.videoFileName}",
        onReceiveProgress: (count, total) {
          setState(() {
            videoModel?.progress = (((count / total) * 10) / 10);
          });
          if (videoModel?.progress == 1) {
            videoModel?.isDownloaded = true;
          }
        },
      );
    } on DioError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${e.error}")));
    }

    if (videoModel?.videoRef?.description != null) {
      createDescription(videoModel);
    }

    if (videoModel == null) return;
    addDataToDB(videoModel.searchUrl);
    videoModel.status = VideoStatus.done;
    dio.close();

    log(videoModel.status.name);
    setState(() {});
  }

  void createDescription(BaseVideoModel? videoModel) {
    final descriptionFile = File("${videoModel?.rootPath}/description.txt");
    descriptionFile.writeAsStringSync(videoModel?.videoRef?.description ?? "");
    log("description file created succesfully");
  }

  void searchYTVideo(String url, BuildContext context) async {
    final newVideo = BaseVideoModel(url);
    textController.clear();
    textFieldNode.unfocus();
    await newVideo.makeSearch(url, context);
    await newVideo.prepareToDownload();

    setState(() {});
  }

  addDataToDB(String? url) {
    instanceDB?.getDBModel?.history?.add(url ?? "null url");
    instanceDB?.writeData();
  }

  //todo crud foor database
  initDB() {
    instanceDB = LocalDatabase.instance;
  }

  Future<void> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
    }
  }

  Future<void> openFile(BaseVideoModel? videoModel) async {}
}
