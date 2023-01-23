import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mvvm/data/apis/api_response.dart';
import 'package:mvvm/data/model/media.dart';
import 'package:mvvm/Presentation/widgets/player_list_widget.dart';
import 'package:mvvm/Presentation/widgets/player_widget.dart';
import 'package:mvvm/Presentation/controllers/controllers.dart';

import 'package:provider/provider.dart';

import '../widgets/SearchWidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget getMediaWidget(BuildContext context, ApiResponse apiResponse) {
    List<Media>? mediaList = apiResponse.data as List<Media>?;
    Media? selectedMedia = Provider.of<controllers>(context).media;

    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.black,
            size: 40,
          ),
        );
      case Status.COMPLETED:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PlayerListWidget(mediaList!, (Media media) {
                Provider.of<controllers>(context, listen: false)
                    .setSelectedMedia(media);
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PlayerWidget(
                  function: () {
                    setState(() {});
                  },
                  mediaList: mediaList,
                ),
              ),
            ),
          ],
        );

      // return Center(
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       ClipRRect(
      //         borderRadius: BorderRadius.circular(12.0),
      //         child: SizedBox(
      //           width: 200,
      //           height: 200,
      //           child: Image.asset("Assets/Images/Looking.png"),
      //         ),
      //       ),
      //       const Text(
      //         'Song Not Found',
      //         style: TextStyle(
      //           fontSize: 18,
      //         ),
      //       ),
      //     ],
      //   ),
      // );
      case Status.ERROR:
        return Center(
          child: Text(apiResponse.message ?? 'Please try again latter!!!'),
        );
      case Status.INITIAL:
      case Status.NOTFOUND:
      default:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset("Assets/Images/Looking.png"),
                ),
              ),
              Text(
                apiResponse.status == Status.INITIAL
                    ? 'Search For A Song'
                    : 'Song Not Found',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputController = TextEditingController();
    ApiResponse apiResponse = Provider.of<controllers>(context).response;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SearchWidget(
                      controller: inputController,
                      onChange: (value) {
                        if (value.isNotEmpty) {
                          Provider.of<controllers>(context, listen: false)
                              .setSelectedMedia(null);
                          Provider.of<controllers>(context, listen: false)
                              .fetchMediaData(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: getMediaWidget(context, apiResponse)),
          ],
        ),
      ),
    );
  }
}
