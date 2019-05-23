# flutter_scan_view

A scan code view that can be embedded in the Widget Tree on iOS and Android..

## Installation
First, add `flutter_scan_view` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS
Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:
* `NSCameraUsageDescription` - describe why your app needs access to the camera. This is called _Privacy - Camera Usage Description_ in the visual editor.

### Android
On Android 6 or higher, you need to request camera permissions first. you can use [permission_handler](https://pub.flutter-io.cn/packages/permission_handler)  to get permission.

### Usage
First import the file
 ```dart
import 'package:flutter_scan_view/flutter_scan_view.dart';
 ```

Define a Controller
 ```dart
FlutterScanViewController _controller;
 ```

Add FlutterScanView to your Widget tree, and save the controller
```dart
FlutterScanView(
                width: 283,
                height: 120,
                onCreated: (controller) {
                  _controller = controller;
                },
              ),
```

You can call `_controller.startScan()` to start scanning and get results
```dart
 _controller.startScan().then((text) {
                          print("Scan Result：${text}");
                        }).catchError((_) {});
```

### Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_scan_view/flutter_scan_view.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterScanViewController _controller;
  String _code = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlutterScanView(
                width: 283,
                height: 120,
                onCreated: (controller) {
                  _controller = controller;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CupertinoButton(
                      child: Text('Start Scan'),
                      onPressed: () {
                        _controller.startScan().then((text) {
                          print("Scan Result：${_code ?? ""}");
                          setState(() {
                            _code = text;
                          });
                        }).catchError((_) {});
                      }),
                  CupertinoButton(
                      child: Text('Stop Scan'),
                      onPressed: () {
                        _controller.stopScan();
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
              ),
              Text("Scan Result：${_code ?? ""}")
            ],
          ))),
    );
  }
}

```