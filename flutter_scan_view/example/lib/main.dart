import 'package:flutter/material.dart';
import 'package:flutter_scan_view/flutter_scan_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterScanViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Center(
            child: FlutterScanView(
              width: 283,
              height: 120,
              onCreated: onCreated,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_controller != null) {
              _controller.startScan().then((result) {
                print(result);
              });
            }
          },
          child: Icon(Icons.scanner),
        ),
      ),
    );
  }

  void onCreated(controller) {
    this._controller = controller;
  }
}
