import 'dart:io';

import 'package:flutter/material.dart';

import './video_player.dart';

import 'package:thumbnails/thumbnails.dart';

final Directory _videoDir =
    new Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

class VideoScreen extends StatefulWidget {
  @override
  VideoScreenState createState() {
    return new VideoScreenState();
  }
}

class VideoScreenState extends State<VideoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_videoDir.path}").existsSync()) {
      return Center(
        child: Text(
          "Install whatsapp to view your friend Status",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else {
      return Container(
        child: VideoGrid(directory: _videoDir),
      );
    }
  }
}

class VideoGrid extends StatefulWidget {
  final Directory directory;

  const VideoGrid({Key key, this.directory}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  _getImage(videoPathUrl) async {
    String thumb = await Thumbnails.getThumbnail(
        videoFile: videoPathUrl, imageType: ThumbFormat.PNG, quality: 10);

    return thumb;
  }

  @override
  Widget build(BuildContext context) {
    var videoList = widget.directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".mp4"))
        .toList(growable: false);

    if (videoList != null) {
      if (videoList.length > 0) {
        return Container(
          child: GridView.builder(
            itemCount: videoList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => Hero(
                        tag: videoList[index],
                        child: VideoPlayer(videoList[index],index,videoList),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: FutureBuilder(
                        future: _getImage(videoList[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Hero(
                                tag: videoList[index],
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        constraints: BoxConstraints.expand(),
                                        child: Image.file(File(snapshot.data),
                                            fit: BoxFit.cover),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Icon(Icons.play_circle_outline,
                                            size: 50, color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          } else {
                            return Hero(
                              tag: videoList[index],
                              child: Container(
                                child: Image.asset(
                                  "assets/video_loader.gif",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }
                        }),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 60.0),
            child: Text(
              "Sorry, No Videos Found.",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
