import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/network/download_manager.dart';
import 'package:yt_downloader/product/searched_handler.dart';
import 'package:yt_downloader/product/video_preview.dart';

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
            bool isDownloaded = false;
            Map<int, int> progress = {};
            bool isDownloadStarted = false;
            return Dismissible(
              onDismissed: (direction) {
                SearchedHolder.instance.getVideoList.removeAt(index);
                setState(() {});
              },
              key: ValueKey("video: ${SearchedHolder.instance.getVideoList[index].title}"),
              child: VideoPreview(
                isDownloaded: isDownloaded,
                video: SearchedHolder.instance.getVideoList[index],
                progress: progress,
                onTap: () async {
                  progress = await downloadVideo(
                      SearchedHolder.instance.getVideoList[index], index, isDownloadStarted);
                  isDownloaded = true;
                  _showSnackbar(context, "Video downloaded");
                  setState(() {});
                },
                isStarted: isDownloadStarted,
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
      leading: Image.network(SearchedHolder.instance.getVideoList[index].thumbnails.highResUrl),
      title: Text(SearchedHolder.instance.getVideoList[index].title),
      subtitle: Text(SearchedHolder.instance.getVideoList[index].description),
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
      SearchedHolder.instance.addVideoToSearched(video);
      textController.clear();
      setState(() {});
    } else if (SearchedHolder.instance.getVideoList.length == 0) {
      searchedBeforeURL = "";
      makeSearch(url, context);
    }
    textController.clear();
  }

  Future downloadVideo(Video? video, int index, bool isStarted) async {
    isStarted = true;
    final manager = DownloadManager();
    if (video == null) return;
    Map<int, int> progress = await manager.downloadVideo(video);
    SearchedHolder.instance.addDownloadedVideo(video);
    SearchedHolder.instance.removeVideoFromSearched(index);
    return progress;
  }

  _showSnackbar(BuildContext context, String data) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
}
