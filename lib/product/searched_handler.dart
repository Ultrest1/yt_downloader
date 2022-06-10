import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchedHolder {
  static SearchedHolder? _instance;
  static SearchedHolder get instance {
    if (_instance != null) return _instance!;
    _instance = SearchedHolder._init();
    return _instance!;
  }

  late final List<Video> _videoList;
  late final List<Video> _downloadedVideoList;
  List<Video> get getVideoList => _videoList;
  List<Video> get getDownloadedVideoList => _downloadedVideoList;

  void addVideoToSearched(Video video) => _videoList.add(video);
  void addDownloadedVideo(Video video) => _downloadedVideoList.add(video);
  void removeVideoFromSearched(int index) => _videoList.removeAt(index);
  void removeFromDownloadedVideo(int index) => _downloadedVideoList.removeAt(index);

  SearchedHolder._init() {
    _videoList = [];
    _downloadedVideoList = [];
  }
}
