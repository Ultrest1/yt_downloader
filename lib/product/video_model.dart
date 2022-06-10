import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class BaseVideoModel {
  Video? video;
  bool isDownloaded = false;
  double? progress;
  BaseVideoModel(Video videoInput) {
    video = videoInput;
  }

  void changeDownloadStat() => isDownloaded = !isDownloaded;
}
