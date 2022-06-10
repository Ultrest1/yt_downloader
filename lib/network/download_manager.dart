import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/product/video_model.dart';

class DownloadManager {
  late final Dio dio;
  DownloadManager() {
    dio = Dio(BaseOptions(
      connectTimeout: 2000,
    ));
  }

  StreamController streamController = StreamController<Map<String, int>>();

  Future downloadVideo(BaseVideoModel? video) async {
    final yt = YoutubeExplode();
    final manifest = await yt.videos.streams.getManifest(video?.video?.id);
    final streamInfo = manifest.muxed.withHighestBitrate();
    if (streamInfo != null) {
      final stream = yt.videos.streamsClient.get(streamInfo);
      final filePath = await FilePicker.platform.getDirectoryPath();
      if (filePath != null) {
        final file = File("$filePath\\${video?.video?.title.replaceAll("|", " ")}.mp4");
        // final progressStream = Stream<Map<String, int>>.fromFuture(future)();
        await dio.download(
          streamInfo.url.toString(),
          file.path,
          onReceiveProgress: (count, total) {
            final progress = "${(count / total * 100).toStringAsFixed(0)}%";
          },
        );
        video?.isDownloaded = true;

        // final fileStream = file.openWrite();

        // await stream.pipe(fileStream);

        // await fileStream.flush();
        // await fileStream.close();
      }
      return false;
    }
    return false;
  }

  Stream<Map<String, dynamic>> progress(int count, int total) async* {
    yield {"count": count, "total": total};
  }
}
