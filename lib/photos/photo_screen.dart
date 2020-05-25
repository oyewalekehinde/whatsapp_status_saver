import 'package:flutter/material.dart';                                                                                import 'dart:io';                                                                                                      import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';                                         import 'package:status_saver/photos/view_photo.dart';                                                                                                                                                                                         final Directory _photoDir =                                                                                                new Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');                                                                                                                                                                            class PhotoScreen extends StatefulWidget {                                                                               @override
  _PhotoScreenState createState() {
    return new _PhotoScreenState();
  }
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory('${_photoDir.path}').existsSync()) {
      return Center(
          child: Text(
        'Install Whatsapp to view your friend Status',
        style: TextStyle(fontSize: 18.0),
      ));
    } else {
      var imageList = _photoDir
          .listSync()
          .map((item) => item.path)
          .where((item) => item.endsWith('.jpg'))
          .toList(growable: false);

      if (imageList.length > 0) {
        return Container(
          padding: EdgeInsets.only(top: 5, left: 5, right: 5),
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              String imgPath = imageList[index];

              return Material(
                elevation: 4,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: InkWell(
                  onTap: () {
                    print(index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewPhotos(imgPath, imageList, index),
                      ),
                    );
                  },
                  child: Hero(
                    tag: imgPath,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Image.file(
                        File(imgPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
            staggeredTileBuilder: (i) =>
                StaggeredTile.count(2, i.isEven ? 2 : 3),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
        );
      } else {
        return Center(
          child: Container(
            padding: EdgeInsets.only(
              bottom: 30,
            ),
            child: Text('Sorry, No Images Found'),
          ),
        );
      }
    }
  }
}