import 'package:mvvm/data/model/media.dart';
import 'package:mvvm/data/dataProvider/media_service.dart';

class MediaRepository {
  // BaseService _mediaService = MediaService();
  final MediaService _mediaService = MediaService();

  Future<List<Media>> fetchMediaList(String value) async {
    dynamic response = await _mediaService.getResponse(value);
    final jsonData = response['results'] as List;
    List<Media> mediaList =
        jsonData.map((tagJson) => Media.fromJson(tagJson)).toList();
    return mediaList;
  }
}
