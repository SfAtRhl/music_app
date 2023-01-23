import 'package:flutter/cupertino.dart';
import 'package:mvvm/data/apis/api_response.dart';
import 'package:mvvm/data/model/media.dart';
import 'package:mvvm/data/Repository/media_repository.dart';

class controllers with ChangeNotifier {
  ApiResponse _apiResponse = ApiResponse.initial('Empty data');

  Media? _media;
  Media? _Forwmedia;
  Media? _Prevmedia;
  bool? _isPlaying;

  ApiResponse get response {
    return _apiResponse;
  }

  Media? get media {
    return _media;
  }

  Media? get Prevmedia {
    return _Prevmedia;
  }

  Media? get Forwmedia {
    return _Forwmedia;
  }

  bool? get isPlaying {
    return _isPlaying;
  }

  /// Call the media service and gets the data of requested media data of
  /// an artist.
  Future<void> fetchMediaData(String value) async {
    _apiResponse = ApiResponse.loading('Fetching artist data');
    notifyListeners();
    try {
      List<Media> mediaList = await MediaRepository().fetchMediaList(value);
      if (mediaList.isEmpty) {
        _apiResponse = ApiResponse.empty("Nothing Found");

      } else {
        _apiResponse = ApiResponse.completed(mediaList);
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      print(e);
    }
    notifyListeners();
  }

  void setSelectedMedia(Media? media) {
    _media = media;
    notifyListeners();
  }

  void setIsPlaying(bool? boolean) {
    _isPlaying = boolean;
    notifyListeners();
  }
}
