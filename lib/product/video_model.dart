import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/product/searched_handler.dart';

class BaseVideoModel {
  Video? video;
  bool isDownloaded = false;
  double? progress;
  String? rootPath;
  BaseVideoModel();

  final Dio _dio = Dio();
  final _yt = YoutubeExplode();
  StreamManifest? _manifest;

  downloadVideoWithHighestBitRate() async {
    if (video == null) {
      return;
    }
    _manifest = await _yt.videos.streams.getManifest(video?.id);
    final streamInfo = _manifest?.muxed.withHighestBitrate();
    if (streamInfo == null) {
      throw Exception("Stream info not initialized yet");
    }
    _yt.videos.streamsClient.get(streamInfo);
    final filePath = await FilePicker.platform.getDirectoryPath();
    if (filePath == null) return;
    final videoFile =
        File("$filePath\\${video?.title.replaceAll("|", " : ")}\\${video?.title.replaceAll("|", " ")}.mp4");
    rootPath = "$filePath\\${video?.title.replaceAll("|", " : ")}";
    log(rootPath ?? "null path");

    await _dio.download(
      streamInfo.url.toString(),
      videoFile.path,
      onReceiveProgress: (count, total) {
        progress = ((count / total) * 100) / 100;
        log(progress.toString());
        if (count == total) {
          log("Download finished");
        }
      },
    );
    if (video?.description != null) {
      final descriptionFile = File("$filePath\\${video?.title.replaceAll("|", " : ")}\\description.txt");
      descriptionFile.writeAsStringSync(video?.description ?? "");
      log("description file created succesfully");
    }

    VideoBucket.instance.addDownloadedVideo(this);
    VideoBucket.instance.removeFromDownloadedVideoWithVideo(this);
  }

  makeSearch(String url, BuildContext context) async {
    if (url == "") {
      _showSnackbar("Please enter valid url", context);
    } else if (!url.contains("youtube.com")) {
      _showSnackbar("Please enter valid url, Check youtube link", context);
    } else {
      try {
        video = await _yt.videos.get(url);
        VideoBucket.instance.addVideoToSearched(this);
      } on SocketException catch (e) {
        _showSnackbar("Check your internet connection. Error: $e", context);
      }
      //setstate
    }
    //controller clear
  }

  void _showSnackbar(String message, BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
