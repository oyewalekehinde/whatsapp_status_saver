import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'format_duration.dart';

class VideoWidget extends StatefulWidget {
  final String filePath;

  VideoWidget(this.filePath);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool visible = true;
  VideoPlayerController videoController;
  final position = ValueNotifier(0.0);
  Future<void> _initialize;

  void initState() {
    super.initState();
    _initialize = (() async {
      videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize();

    })();

    videoController.addListener(() {
      if (videoController.value.isPlaying) {
        position.value = videoController.value.position.inMilliseconds /
            videoController.value.duration.inMilliseconds;
      }
      if (videoController.value.position >= videoController.value.duration) {
        position.value = 0.0;
      }
    });
  }

  void dispose() {
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoController,
      builder: (context, val, child) {
        return FutureBuilder(
          future: _initialize,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            visible = !visible;
                          });

                          print('video clicked');
                        },
                        child: AspectRatio(
                          aspectRatio: videoController.value.aspectRatio,
                          child: VideoPlayer(videoController),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1.0,
                      left: 0.0,
                      right: 0.0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: visible ? 1.0 : 0.0,
                        child: Container(
                          color: Colors.white.withOpacity(0.6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: _buildPlayPause(videoController),
                              ),
                              _buildPosition(),
                              ValueListenableBuilder(
                                valueListenable: position,
                                builder: (context, val, child) {
                                  return VidSlider(
                                    pos: position,
                                    upDatePos: (valu) {
                                      final curPos = videoController
                                          .value.duration.inMilliseconds;
                                      position.value = valu;
                                      final nwPos = curPos * valu;
                                      videoController.seekTo(
                                        Duration(
                                          milliseconds: nwPos.floor(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: _buildMuteButton(videoController),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child:Text('Loading........',style:TextStyle(color: Colors.white,fontSize: 20)),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildPosition() {
    final position = videoController.value.position;
    final duration = videoController.value.duration;

    return Container(
      child: Text(
        '${formatDuration(position)} / ${formatDuration(duration)}',
        style: TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(VideoPlayerController controller) {
    return GestureDetector(
      onTap: _playPause,
      child: Icon(
        controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
      ),
    );
  }

  void _playPause() {
    bool isFinished =
        videoController.value.position >= videoController.value.duration;

    setState(() {
      if (videoController.value.isPlaying) {
        videoController.pause();
      } else {
        if (!videoController.value.initialized) {
          videoController.initialize().then((_) {
            videoController.play();
          });
        } else {
          if (isFinished) {
            videoController.seekTo(Duration(seconds: 0));
          }
          videoController.play();
        }
      }
    });
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController videoController,
  ) {
    return GestureDetector(
      onTap: () {
        if (videoController.value.volume == 0) {
          videoController.setVolume(20);
        } else {
          videoController.setVolume(0.0);
        }
      },
      child: Icon(
        (videoController.value != null && videoController.value.volume > 0)
            ? Icons.volume_up
            : Icons.volume_off,
        color: Colors.white,
      ),
    );
  }
}

class VidSlider extends StatelessWidget {
  final Function upDatePos;
  final ValueListenable pos;

  VidSlider({this.upDatePos, this.pos});

  @override
  Widget build(BuildContext context) {
    return Slider(
      activeColor: Colors.black,
      value: pos.value,
      onChanged: (val) => upDatePos(val),
    );
  }
}