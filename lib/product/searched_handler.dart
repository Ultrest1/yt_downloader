import 'package:yt_downloader/product/video_model.dart';

class VideoBucket {
  static VideoBucket? _instance;
  static VideoBucket get instance {
    if (_instance != null) return _instance!;
    _instance = VideoBucket._init();
    return _instance!;
  }

  late final List<BaseVideoModel?> _searchedNotDownloaded;
  late final List<BaseVideoModel?> _downloadedVideoList;
  List<BaseVideoModel?> get getSearchedNotDownloadedVideoList => _searchedNotDownloaded;
  List<BaseVideoModel?> get getDownloadedVideoList => _downloadedVideoList;

  void addVideoToSearched(BaseVideoModel? video) => _searchedNotDownloaded.add(video);
  void addDownloadedVideo(BaseVideoModel? video) => _downloadedVideoList.add(video);

  void removeVideoFromSearched(int index) => _searchedNotDownloaded.removeAt(index);
  void removeVideoFromSearchedWithVideo(BaseVideoModel video) => _searchedNotDownloaded.remove(video);

  void removeFromDownloadedVideo(int index) => _downloadedVideoList.removeAt(index);
  void removeFromDownloadedVideoWithVideo(BaseVideoModel video) => _downloadedVideoList.remove(video);

  VideoBucket._init() {
    _searchedNotDownloaded = [];
    _downloadedVideoList = [];
  }
}
