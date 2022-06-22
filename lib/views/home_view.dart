// ignore_for_file: prefer_is_empty

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
  final String searchedBeforeURL = "";
  final String hintText = "search.. www.youtube.com";
  final String noVideo = "No video yet";
  final String nullTitle = "Null title";
  final String nullAuthor = "null author";
  final String openText = "Open";
  final String downloadText = "Download";
  final String nullDescrip = "null description";
  final String ytLink = "www.youtube.com";
  late final LocalDatabase? instanceDB;

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
      body: Column(
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
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget buildList() {
    if (VideoDownloadHsistory.instance.getVideoList.length == 0) {
      return Center(child: Text(noVideo));
    } else {
      return Expanded(
          child: ListView.builder(
        itemBuilder: (context, index) {
          final video = VideoDownloadHsistory.instance.getVideoList[index];
          return videoCard(index, video, context);
        },
        itemCount: VideoDownloadHsistory.instance.getVideoList.length,
      ));
    }
  }

  VideoCard videoCard(int index, BaseVideoModel? video, BuildContext context) {
    return VideoCard(
      videoModel: video ?? BaseVideoModel(""),
      downloadVidFunc: () async {
        await downloadvid(VideoDownloadHsistory.instance.getVideoList[index]);
        setState(() {});
      },
      dropdown: (p) {
        video?.dropdownValue = p;
        setState(() {});
      },
      openFunc: () async {
        final Uri uri = Uri.file("${video?.rootPath}\\${video?.videoFileName}");
        if (await canLaunchUrlString(uri.path)) {
          log("can launch");
        }
        // await launchUrlString("${video?.rootPath}\\${video?.videoFileName}");
      },
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
    await videoModel?.generatePathFile();
    if (isOkay == false) return;

    await checkPermission();
    videoModel?.status = VideoStatus.downloading;
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
    addDataToDB(videoModel.searchUrl);
    videoModel.status = VideoStatus.done;
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
}
