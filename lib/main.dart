import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/photos/photo_screen.dart';
import 'package:status_saver/videos/video_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _storagePermissionCheck;
  Future<int> _storagePermissionChecker;
  Future<int> checkStoragePermission() async {
    PermissionStatus result = await Permission.storage.status;

    print("Checking Storage Permission " + result.toString());
    setState(() {
      _storagePermissionCheck = 1;
    });
    if (result.toString() == 'PermissionStatus.denied') {
      return 0;
    } else if (result.toString() == 'PermissionStatus.granted') {
      return 1;
    } else if (result.toString() == 'PermissionStatus.permanentlyDenied') {
      return 2;
    } else {
      return 0;
    }
  }

  Future<int> requestStoragePermission() async {
    PermissionStatus result = await Permission.storage.request();

    print(result.toString());
    if (result.toString() == 'PermissionStatus.denied') {
      return 0;
    } else if (result.toString() == 'PermissionStatus.granted') {
      return 1;
    } else if (result.toString() == 'PermissionStatus.permanentlyDenied') {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  void initState() {
    super.initState();

    _storagePermissionChecker = (() async {
      int storagePermissionCheckInt;
      int finalPermission;

      print("Initial Values of $_storagePermissionCheck");
      if (_storagePermissionCheck == null || _storagePermissionCheck == 0) {
        _storagePermissionCheck = await checkStoragePermission();
      } else {
        _storagePermissionCheck = 1;
      }
      if (_storagePermissionCheck == 1) {
        storagePermissionCheckInt = 1;
      } else if (_storagePermissionCheck == 0) {
        storagePermissionCheckInt = 0;
      } else {
        storagePermissionCheckInt = 2;
      }

      if (storagePermissionCheckInt == 1) {
        finalPermission = 1;
      } else if (_storagePermissionCheck == 2) {
        finalPermission = 2;
      } else {
        finalPermission = 0;
      }

      return finalPermission;
    })();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Status-Saver",
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Status-Saver'),
            bottom: TabBar(tabs: <Widget>[
              Tab(
                icon: Icon(Icons.photo_library),
                text: 'Photos',
              ),
              Tab(
                icon: Icon(Icons.video_library),
                text: 'Videos',
              ),
            ]),
          ),
          body: FutureBuilder(
            future: _storagePermissionChecker,
            builder: (context, status) {
              if (status.connectionState == ConnectionState.done) {
                if (status.hasData) {
                  if (status.data == 1) {

                    return TabBarView(
                      children: <Widget>[PhotoScreen(), VideoScreen()],
                    );
                  } else if (status.data == 2) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'You have permantely denied permission\n Open App setting to accept manually',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.settings_applications),
                            onPressed: () {
                              openAppSettings();
                              Future.delayed(Duration(seconds: 3) , ()=> SystemNavigator.pop());
                              },
                            label: Text(
                              'Settings',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                          )
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Storage Permission Required",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              "Allow Storage Permission",
                              style: TextStyle(fontSize: 20.0),
                            ),
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _storagePermissionChecker =
                                    requestStoragePermission();
                              });
                            },
                          )
                        ],
                      ),
                    );
                  }
                } else {
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Something went wrong.. Please relaunch",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.exit_to_app),
                            onPressed: () => SystemNavigator.pop(),
                            label: Text('Exit'),
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}