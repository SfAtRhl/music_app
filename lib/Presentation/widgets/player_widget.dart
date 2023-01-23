import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../data/model/media.dart';
import '../../Presentation/controllers/controllers.dart';
import 'package:provider/provider.dart';

enum PlayerState { stopped, playing, paused }

enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final PlayerMode mode;
  final Function function;
  final List<Media> mediaList;

  const PlayerWidget(
      {Key? key,
      required this.function,
      this.mode = PlayerMode.MEDIA_PLAYER,
      required this.mediaList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? _prevSongName;
  PlayerMode mode;

  late AudioPlayer _audioPlayer;
  int _duration = 100;
  int _position = 0;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  _PlayerWidgetState(this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void playCurrentMedia(Media? media) {
    if (media != null && _prevSongName 
    != media.trackName) {
      _prevSongName = media.trackName;
      _position = 0;
      _stop();
      if (Provider.of<controllers>(context).isPlaying == false) {
        Provider.of<controllers>(context).setIsPlaying(true);
      }
      play(media);
    }
  }

  @override
  Widget build(BuildContext context) {
    Media? media = Provider.of<controllers>(context).media;

    playCurrentMedia(media);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: (media != null)
                    ? Image.network(media.artworkUrl ?? '')
                    : Image.asset("Assets/Images/NoMusic2.png"),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    media == null
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.fast_rewind,
                              size: 25.0,
                              color: Color(0xFF787878),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              for (var i = 0;
                                  i < widget.mediaList.length;
                                  i++) {
                                var let = getindex(widget.mediaList, media);
                                if (i == let - 1) {
                                  Provider.of<controllers>(context,
                                          listen: false)
                                      .setSelectedMedia(widget.mediaList[i]);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.fast_rewind,
                              size: 25.0,
                              color: getindex(widget.mediaList, media) == 0
                                  ? const Color(0xFF787878)
                                  : Colors.black,
                            ),
                          ),
                    ClipOval(
                        child: Container(
                      color: Colors.black,
                      width: 50.0,
                      height: 50.0,
                      child: IconButton(
                        onPressed: () {
                          if (_isPlaying) {
                            Provider.of<controllers>(context, listen: false)
                                .setIsPlaying(false);
                            _pause();
                          } else {
                            Provider.of<controllers>(context, listen: false)
                                .setIsPlaying(true);
                            play(media!);
                          }
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    )),
                    media == null
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.fast_forward,
                              size: 25.0,
                              color: Color(0xFF787878),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              for (var i = 0;
                                  i < widget.mediaList.length;
                                  i++) {
                                var let = getindex(widget.mediaList, media);
                                if (i == let + 1) {
                                  Provider.of<controllers>(context,
                                          listen: false)
                                      .setSelectedMedia(widget.mediaList[i]);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.fast_forward,
                              size: 25.0,
                              color: getindex(widget.mediaList, media) ==
                                      widget.mediaList.length - 1
                                  ? const Color(0xFF787878)
                                  : Colors.black,
                            ),
                          ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Stack(
                        children: [
                          Slider(
                            activeColor: Colors.black,
                            inactiveColor: Colors.blue.shade400,
                            value: double.parse(_position.toString()),
                            min: 0,
                            max: double.parse(_duration.toString()),
                            divisions: _duration,
                            onChanged: (double value) async {
                              int seekval = value.round();
                              int result = await _audioPlayer
                                  .seek(Duration(milliseconds: seekval));
                              if (result == 1) {
                                _position = seekval;
                              } else {
                                print("Seek unsuccessful.");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration.inMilliseconds);

      // if (Theme.of(context).platform == TargetPlatform.iOS) {
      //   _audioPlayer.();

      //   _audioPlayer.setNotification(
      //       title: 'App Name',
      //       artist: 'Artist or blank',
      //       albumTitle: 'Name or blank',
      //       imageUrl: 'url or blank',
      //       forwardSkipInterval: const Duration(seconds: 30),
      //       backwardSkipInterval: const Duration(seconds: 30),
      //       duration: duration,
      //       elapsedTime: const Duration(seconds: 0));
      // }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p.inMilliseconds;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      // _onReplay();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = 0;
        _position = 0;
      });
    });
  }

  Future<int> play(Media media) async {
    final playPosition =
        (_position > 0 && _position < _duration) ? _position / _duration : null;
    final result = await _audioPlayer.play(media.previewUrl!);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    _audioPlayer.setPlaybackRate(1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
      });
    }
    return result;
  }

  void _onComplete() {
    // Provider.of<MediaViewModel>(context,
    //                                       listen: false)
    //                                   .setSelectedMedia(widget.mediaList[i]);
    // Media? media = Provider.of<MediaViewModel>(context, listen: false).media;
    // Provider.of<MediaViewModel>(context, listen: false).setIsPlaying(false);
    setState(() => _playerState = PlayerState.stopped);
    // playCurrentMedia(media);
  }

  void _onReplay() {
    // Provider.of<MediaViewModel>(context,
    //                                       listen: false)
    //                                   .setSelectedMedia(widget.mediaList[i]);
    Media? media = Provider.of<controllers>(context).media;
    // Provider.of<MediaViewModel>(context, listen: false).setIsPlaying(false);
    // setState(() => _playerState = PlayerState.stopped);
    play(media!);
  }
}

int getindex(mediaList, selectedMedia) {
  var let = mediaList
      .indexWhere((element) => element.previewUrl == selectedMedia.previewUrl);
  return let;
}
