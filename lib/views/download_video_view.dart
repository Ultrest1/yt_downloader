import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/network/download_manager.dart';
import 'package:yt_downloader/product/searched_handler.dart';
import 'package:yt_downloader/product/video_preview.dart';

import '../product/video_model.dart';

class DownloadVideo extends StatefulWidget {
  DownloadVideo({Key? key}) : super(key: key);

  @override
  State<DownloadVideo> createState() => _DownloadVideoState();
}

class _DownloadVideoState extends State<DownloadVideo> {
  List<Video?> videoList = [];

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
    if (SearchedHolder.instance.getVideoList.length == 0) {
      return const Center(child: Text("No video yet"));
    } else {
      return Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Dismissible(
              onDismissed: (direction) {
                SearchedHolder.instance.getVideoList.removeAt(index);
                setState(() {});
              },
              key: ValueKey("video: ${SearchedHolder.instance.getVideoList[index]?.video?.title}"),
              child: Column(
                children: [
                  VideoPreview(
                    video: SearchedHolder.instance.getVideoList[index],
                    onTap: () async {
                      await downloadVideo(
                        SearchedHolder.instance.getVideoList[index],
                        index,
                      );
                    },
                  ),
                ],
              ),
            );
          },
          itemCount: SearchedHolder.instance.getVideoList.length,
        ),
      );
    }
  }

  Future<ListTile> listtile(int index) async {
    return ListTile(
      leading: Image.network(SearchedHolder.instance.getVideoList[index]?.video?.thumbnails.highResUrl ?? ""),
      title: Text(SearchedHolder.instance.getVideoList[index]?.video?.title ?? "null title"),
      subtitle: Text(SearchedHolder.instance.getVideoList[index]?.video?.description ?? "null description"),
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
                controller: textController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "www.youtube.com")),
          ),
        ),
        ElevatedButton(
            onPressed: () => makeSearch(textController.text, context),
            child: const Padding(padding: EdgeInsets.all(8), child: Text("Check Video")))
      ],
    );
  }

  void makeSearch(String url, BuildContext context) async {
    if (textController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid url")));
    } else if (searchedBeforeURL != textController.text) {
      final yt = YoutubeExplode();
      final video = await yt.videos.get(textController.text);
      searchedBeforeURL = textController.text;
      SearchedHolder.instance.addVideoToSearched(BaseVideoModel(video));
      textController.clear();
      setState(() {});
    } else if (SearchedHolder.instance.getVideoList.length == 0) {
      searchedBeforeURL = "";
      makeSearch(url, context);
    }
    textController.clear();
  }

  // Future downloadVideo(BaseVideoModel? video, int index) async {
  //   final manager = DownloadManager();
  //   if (video == null) return;
  //   var progress = await manager.downloadVideo(video);

  //   SearchedHolder.instance.addDownloadedVideo(video);
  //   SearchedHolder.instance.removeVideoFromSearched(index);
  //   return progress;
  // }

  Future downloadVideo(BaseVideoModel? video, int index) async {
    final yt = YoutubeExplode();
    final dio = Dio();
    final manifest = await yt.videos.streams.getManifest(video?.video?.id);
    final streamInfo = manifest.muxed.withHighestBitrate();
    yt.videos.streamsClient.get(streamInfo);
    final filePath = await FilePicker.platform.getDirectoryPath();
    if (filePath == null) return;
    final file = File("$filePath\\${video?.video?.title.replaceAll("|", " ")}.mp4");
    await dio.download(
      streamInfo.url.toString(),
      file.path,
      onReceiveProgress: (count, total) {
        setState(() {
          video?.progress = ((count / total) * 100) / 10;
        });
        if (video?.progress == 100) {
          video?.isDownloaded = true;
        }
      },
    );

    video?.isDownloaded = true;
    SearchedHolder.instance.addDownloadedVideo(video);
    SearchedHolder.instance.removeVideoFromSearched(index);
  }
}
