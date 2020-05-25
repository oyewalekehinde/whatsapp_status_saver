import 'dart:io';

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_extend/share_extend.dart';

class ViewPhotos extends StatefulWidget {
  final String imgPath;
  final List imgList;
  final int _index;

  ViewPhotos(this.imgPath, this.imgList, this._index);

  @override
  _ViewPhotosState createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  var filePath;

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
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: widget.imgList.length,
            controller: PageController(initialPage: widget._index),
            itemBuilder: (context, index) => Stack(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: Image.file(
                    File(widget.imgList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400.withOpacity(0.2),
                        )),
                  ),
                ),
                Container(
                  constraints: BoxConstraints.expand(),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                          tag: widget.imgList[index],
                          child: Image.file(
                            File(widget.imgList[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
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

                          Uri myUri = Uri.parse(widget.imgList[index]);

                          File originalImageFile = File.fromUri(myUri);

                          Uint8List bytes;

                          await originalImageFile.readAsBytes().then((value) {
                            bytes = Uint8List.fromList(value);

                            print('reading of bytes is completed');
                          }).catchError((onError) {
                            print(
                                'Exception Error while reading audio from path:' 
                                  +  onError.toString());
                          });

                          final result = await ImageGallerySaver.saveImage(
                              Uint8List.fromList(bytes));

                          print(result);

                          _onLoading(false,
                              "If Image not available in gallery\n\nYou can find all images at");
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
                            File filepath = File(widget.imgList[index]);
                            if (filepath != null) {
                              ShareExtend.share(filepath.path, "image",
                                  sharePanelTitle: 'Share Image using');
                            }
                          },
                        ),
                      ),
                    ],
                  ),                                                                                                                   
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}