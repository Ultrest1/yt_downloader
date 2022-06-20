// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'base_video_model.dart';

class VideoDownloadHsistory {
  static VideoDownloadHsistory? _instance;
  static VideoDownloadHsistory get instance {
    if (_instance != null) return _instance!;
    _instance = VideoDownloadHsistory._init();
    return _instance!;
  }

  late final List<BaseVideoModel?> _searchedVideo;
  List<BaseVideoModel?> get getVideoList => _searchedVideo;

  void addVideoToHistory(BaseVideoModel? video) => _searchedVideo.add(video);

  void removeVideo(int index) => _searchedVideo.removeAt(index);
  void removeVideoWithVideo(BaseVideoModel video) =>
      _searchedVideo.remove(video);

  VideoDownloadHsistory._init() {
    _searchedVideo = [];
  }

  generateListOfLinks() {
    List<String> links = [];

    for (var link in _searchedVideo) {
      print(link.runtimeType);
      if (link?.videoRef?.url != null && link?.videoRef?.url != "") {
        links.add(link?.videoRef?.url ?? "");
      }
    }
  }
}
