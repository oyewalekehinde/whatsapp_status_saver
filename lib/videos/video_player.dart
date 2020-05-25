import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:share_extend/share_extend.dart';

import 'video_controller.dart';

class VideoPlayer extends StatefulWidget {
  final String filePath;
  final int _index;
  final List videoList;

  VideoPlayer(this.filePath,this._index,this.videoList);

  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void _onLoading(bool t, String str) {
    if (t) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Center(
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator()),
                ),
              ],
            );
          });
    } else {
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialog(
                 shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Great, Saved in Gallery",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text(str,
                              style: TextStyle(
                                fontSize: 16.0,
                              )),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text("FileManager > Downloaded Status",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.teal)),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          MaterialButton(
                            child: Text("Close"),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: widget.videoList.length,
            controller: PageController(initialPage: widget._index),
            itemBuilder: (context, index) =>
          Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  bottom: 60,
                ),
                color: Colors.black,
                child: VideoWidget(widget.videoList[index]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        color: Colors.indigo,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    FlatButton.icon(
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      icon: Icon(Icons.file_download),
                      label: Text(
                        'Download',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () async {
                        _onLoading(true, "");
                        File originalVideoFile = File(widget.filePath);
                        Directory directory = await getExternalStorageDirectory();
                        if (!Directory("${directory.path}/Downloaded Status/Videos")
                            .existsSync()) {
                          Directory("${directory.path}/Downloaded Status/Videos")
                              .createSync(recursive: true);
                        }
                        String path = directory.path;
                        String curDate = DateTime.now().toString();
                        String newFileName =
                            "$path/Downloaded Status/Videos/VIDEO-$curDate.mp4";

                        await originalVideoFile.copy(newFileName);

                        _onLoading(false,
                            "If Video not available in gallery\n\nYou can find all videos at");
                      },
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () async {
                          File filepath = File(widget.videoList[index]);
                          if (filepath != null) {
                            ShareExtend.share(filepath.path, "video",
                                sharePanelTitle: "Share Video using");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

      ),
    );
  }
}