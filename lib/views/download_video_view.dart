import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../product/searched_handler.dart';
import '../product/video_preview.dart';

import '../product/video_model.dart';

class DownloadVideo extends StatefulWidget {
  const DownloadVideo({Key? key}) : super(key: key);

  @override
  State<DownloadVideo> createState() => _DownloadVideoState();
}

class _DownloadVideoState extends State<DownloadVideo> {
  List<BaseVideoModel?> videoList = [];

  final textController = TextEditingController();
  String searchedBeforeURL = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          inputArea(),
          const Divider(),
          buildList(),
        ],
      ),
    );
  }

  Widget buildList() {
    // ignore: prefer_is_empty
    if (VideoBucket.instance.getSearchedNotDownloadedVideoList.length == 0) {
      return const Center(child: Text("No video yet"));
    } else {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Dismissible(
              onDismissed: (direction) {
                VideoBucket.instance.getSearchedNotDownloadedVideoList.removeAt(index);
                setState(() {});
              },
              key: ValueKey(
                  "video: ${VideoBucket.instance.getSearchedNotDownloadedVideoList[index]?.videoRef?.title}"),
              child: Column(
                children: [
                  VideoPreview(
                    video: VideoBucket.instance.getSearchedNotDownloadedVideoList[index],
                    onTap: () async {
                      downloadvid(VideoBucket.instance.getSearchedNotDownloadedVideoList[index]);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
          itemCount: VideoBucket.instance.getSearchedNotDownloadedVideoList.length,
        ),
      );
    }
  }

  Future<ListTile> listtile(int index) async {
    return ListTile(
      leading: Image.network(
          VideoBucket.instance.getSearchedNotDownloadedVideoList[index]?.videoRef?.thumbnails.highResUrl ??
              ""),
      title: Text(
          VideoBucket.instance.getSearchedNotDownloadedVideoList[index]?.videoRef?.title ?? "null title"),
      subtitle: Text(VideoBucket.instance.getSearchedNotDownloadedVideoList[index]?.videoRef?.description ??
          "null description"),
      trailing: IconButton(onPressed: () async {}, icon: const Icon(Icons.download)),
    );
  }

  Row inputArea() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                onSubmitted: (value) => searchYTVideo(textController.text, context),
                controller: textController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "www.youtube.com")),
          ),
        ),
        ElevatedButton(
            onPressed: () => searchYTVideo(textController.text, context),
            child: const Padding(padding: EdgeInsets.all(8), child: Text("Check Video")))
      ],
    );
  }

  Future<void> downloadvid(BaseVideoModel? videoModel) async {
    final dio = Dio();
    final isOkay = await videoModel?.prepareToDownload();
    if (isOkay == false) return;

    await dio.download(
      videoModel?.streamInfo?.url.toString() ?? "",
      "${videoModel?.rootPath}\\${videoModel?.videoFileName}.mp4",
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
    addAndRemoveFromList(videoModel);
  }

  void createDescription(BaseVideoModel? videoModel) {
    final descriptionFile = File("${videoModel?.rootPath}\\description.txt");

    descriptionFile.writeAsStringSync(videoModel?.videoRef?.description ?? "");
    log("description file created succesfully");
  }

  void searchYTVideo(String url, BuildContext context) async {
    final newVideo = BaseVideoModel();
    await newVideo.makeSearch(url, context);
    textController.clear();
    setState(() {});
  }

  void addAndRemoveFromList(BaseVideoModel model) {
    VideoBucket.instance.addDownloadedVideo(model);
    VideoBucket.instance.removeVideoFromSearchedWithVideo(model);
  }
}
