import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'searched_handler.dart';

class BaseVideoModel {
  Video? videoRef;
  bool isDownloaded = false;
  double? progress;
  String? rootPath;
  String? videoFileName;
  String? descriptionName;
  void Function(int count, int total)? onReceiveProgress;
  BaseVideoModel();

  final _yt = YoutubeExplode();
  StreamManifest? manifest;
  MuxedStreamInfo? streamInfo;

  Future<bool> prepareToDownload() async {
    if (videoRef == null) {
      return false;
    }
    manifest = await _yt.videos.streams.getManifest(videoRef?.id);
    streamInfo = manifest?.muxed.withHighestBitrate();
    if (streamInfo == null) {
      throw Exception("Stream info not initialized yet");
    }
    if (streamInfo == null) return false;
    _yt.videos.streamsClient.get(streamInfo!);
    await _generatePathFile();
    if (rootPath == null) return false;

    return true;
  }

  Future<String?> _generatePathFile() async {
    final filePath = await FilePicker.platform.getDirectoryPath();
    if (filePath == null) return "";
    rootPath = "$filePath\\$fixTitle";

    videoFileName = "$fixTitle.mp4";
    descriptionName = "$rootPath\\description.txt";

    return rootPath;
  }

  String? get fixTitle => videoRef?.title
      .replaceAll("ü", "u")
      .replaceAll("ğ", "g")
      .replaceAll("ı", "i")
      .replaceAll("ç", "c")
      .replaceAll("ş", "s")
      .replaceAll("Ü", "U")
      .replaceAll("Ğ", "G")
      .replaceAll("?", "")
      .replaceAll("İ", "I")
      .replaceAll("Ç", "C")
      .replaceAll("Ş", "S")
      .replaceAll(":", "")
      .replaceAll("!", "");

  Future<void> makeSearch(String url, BuildContext context) async {
    bool isSearchedBefore = false;
    if (url == "") {
      _showSnackbar("Please enter valid url", context);
    } else if (!url.contains("youtube.com")) {
      _showSnackbar("Please enter valid url, Check youtube link", context);
    } else {
      isSearchedBefore = checkSearchedBefore(url);
      if (isSearchedBefore) return;
      try {
        videoRef = await _yt.videos.get(url);
        VideoBucket.instance.addVideoToSearched(this);
      } on SocketException catch (e) {
        log("message: ${e.message}");
        _showSnackbar("Check your internet connection. Error: $e", context);
      }
      //setstate
    }
    //controller clear
  }

  void _showSnackbar(String message, BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  bool checkSearchedBefore(String url) {
    for (var element in VideoBucket.instance.getSearchedNotDownloadedVideoList) {
      if (element?.videoRef?.url == url) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'BaseVideoModel(videoRef: $videoRef, isDownloaded: $isDownloaded, progress: $progress, rootPath: $rootPath, onReceiveProgress: $onReceiveProgress)';
  }
}
