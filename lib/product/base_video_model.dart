// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'searched_handler.dart';

class BaseVideoModel {
  Video? videoRef;
  String? searchUrl;
  bool isDownloaded = false;
  double? progress;
  String? rootPath;
  String? videoFileName;
  String? selectedOptionSize;
  String? descriptionAdress;
  VideoStatus status = VideoStatus.waiting;
  List<AvailableOption> options = [];
  AvailableOption? dropdownValue;
  BaseVideoModel(this.searchUrl) {
    prepareToDownload();
  }

  final _yt = YoutubeExplode();
  StreamManifest? manifest;
  VideoStreamInfo? streamInfo;

  void getQualities() {}

  Future<bool> prepareToDownload() async {
    if (videoRef == null) return false;

    manifest = await _yt.videos.streams.getManifest(videoRef?.id);

    if (manifest == null) return false;
    for (var element in manifest!.video) {
      if (!element.qualityLabel.toString().contains("1080")) {
        streamInfo = element;
        options.add(AvailableOption(
          format: element.videoCodec,
          qualityLabel: element.videoQuality.name,
          resolution: VideoResolution(
              element.videoResolution.width, element.videoResolution.height),
          size: element.size.totalMegaBytes,
          url: element.url,
        ));
      }
    }
    dropdownValue = options.first;
    if (streamInfo == null) {
      throw Exception("Stream info not initialized yet");
    }
    if (streamInfo == null) return false;
    // _yt.videos.streamsClient.get(streamInfo!);
    // await _generatePathFile();
    // if (rootPath == null) return false;

    return true;
  }

  Widget toDropDown({required void Function(AvailableOption?)? onChanged}) {
    return DropdownButton(
        alignment: Alignment.center,
        borderRadius: BorderRadius.circular(20),
        value: dropdownValue,
        items: options.map((e) {
          selectedOptionSize = e.size?.toStringAsFixed(2);
          return DropdownMenuItem(
              value: e,
              child: Row(
                children: [
                  Text("${e.qualityLabel} "),
                ],
              ));
        }).toList(),
        onChanged: onChanged);
  }

  Future<String?> generatePathFile() async {
    final filePath = await FilePicker.platform.getDirectoryPath();
    if (filePath == null) return "";
    rootPath = "$filePath/$fixTitle";

    videoFileName = "$fixTitle.mp4";
    descriptionAdress = "$rootPath/description.txt";

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
        VideoDownloadHsistory.instance.addVideoToHistory(this);
      } on SocketException catch (e) {
        log("message: ${e.message}");
        _showSnackbar("Check your internet connection. Error: $e", context);
      }
      //setstate
    }
    //controller clear
  }

  void _showSnackbar(String message, BuildContext context) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  bool checkSearchedBefore(String url) {
    for (var element in VideoDownloadHsistory.instance.getVideoList) {
      if (element?.videoRef?.url == url) {
        return true;
      }
    }
    return false;
  }
}

class AvailableOption {
  String? format;
  VideoResolution? resolution;
  String? qualityLabel;
  double? size;
  Uri? url;
  AvailableOption({
    this.format,
    this.resolution,
    this.qualityLabel,
    this.size,
    this.url,
  });
}

enum VideoStatus {
  waiting,
  downloading,
  done,
}
