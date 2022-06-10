import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/product/video_model.dart';

class SearchedHolder {
  static SearchedHolder? _instance;
  static SearchedHolder get instance {
    if (_instance != null) return _instance!;
    _instance = SearchedHolder._init();
    return _instance!;
  }

  late final List<BaseVideoModel?> _videoList;
  late final List<BaseVideoModel?> _downloadedVideoList;
  List<BaseVideoModel?> get getVideoList => _videoList;
  List<BaseVideoModel?> get getDownloadedVideoList => _downloadedVideoList;

  void addVideoToSearched(BaseVideoModel? video) => _videoList.add(video);
  void addDownloadedVideo(BaseVideoModel? video) => _downloadedVideoList.add(video);
  void removeVideoFromSearched(int index) => _videoList.removeAt(index);
  void removeFromDownloadedVideo(int index) => _downloadedVideoList.removeAt(index);

  SearchedHolder._init() {
    _videoList = [];
    _downloadedVideoList = [];
  }
}
