import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadManager {
  late final Dio dio;
  DownloadManager() {
    dio = Dio(BaseOptions(
      connectTimeout: 2000,
    ));
  }

  Future downloadVideo(Video? video) async {
    final yt = YoutubeExplode();
    final manifest = await yt.videos.streams.getManifest(video?.id);
    final streamInfo = manifest.muxed.withHighestBitrate();
    if (streamInfo != null) {
      final stream = yt.videos.streamsClient.get(streamInfo);
      final filePath = await FilePicker.platform.getDirectoryPath();
      if (filePath != null) {
        final file = File("$filePath\\${video?.title.replaceAll("|", " ")}.mp4");
        late Map<int, int> progress;
        final response = await dio.download(
          streamInfo.url.toString(),
          file.path,
          onReceiveProgress: (count, total) {
            progress = {count: total};
          },
        );
        // final fileStream = file.openWrite();

        // await stream.pipe(fileStream);

        // await fileStream.flush();
        // await fileStream.close();
        return progress;
      }
      return false;
    }
    return false;
  }
}
