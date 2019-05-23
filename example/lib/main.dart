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
                          print("Scan Result：$text");
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
