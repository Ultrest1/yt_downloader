// ignore_for_file: prefer_is_empty

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:yt_downloader/product/video_preview.dart';
import 'package:yt_downloader/utils/local_database/local_database.dart';
import 'package:yt_downloader/utils/local_database/user_db.dart';
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
  late final UserDB? db;

  @override
  void initState() {
    initDatabase();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldNode.dispose();
    super.dispose();
  }

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
              ? const SizedBox()
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
          return videoCard(index, video, context);
        },
        itemCount: VideoDownloadHsistory.instance.getVideoList.length,
      ));
    }
  }

  VideoCard videoCard(int index, BaseVideoModel? video, BuildContext context) {
    return VideoCard(
        videoModel: video ?? BaseVideoModel(""),
        downloadVidFunc: () {
          downloadvid(VideoDownloadHsistory.instance.getVideoList[index]);
          setState(() {});
        });
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
    db = dbInstance?.readFile();
  }

  addDataToDB() {
    db?.history?.add(textController.text);
    dbInstance?.addData(db);
    db = dbInstance?.readFile();
    setState(() {});
  }
  //todo crud foor database
}
