import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef void FlutterScanViewCreatedCallback(
    FlutterScanViewController controller);

class FlutterScanViewController {
  MethodChannel _channel;

  FlutterScanViewController.init(int id) {
    _channel = MethodChannel('plugins.flutter.io/njscanview_$id');
  }

  Future<String> startScan() async {
    final String result = await _channel.invokeMethod('start');
    return result;
  }

  Future<void> stopScan() async {
    return _channel.invokeMethod('stop');
  }
}

class FlutterScanView extends StatefulWidget {
  final FlutterScanViewCreatedCallback onCreated;
  final double width;
  final double height;

  FlutterScanView(
      {Key key, @required this.onCreated, this.width = 0, this.height = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlutterScanViewState();
}

class _FlutterScanViewState extends State<FlutterScanView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: AndroidView(
          viewType: 'plugins.flutter.io/njscanview',
          onPlatformViewCreated: onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'width': widget.width,
            'height': widget.height,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: UiKitView(
          viewType: 'plugins.flutter.io/njscanview',
          onPlatformViewCreated: onPlatformViewCreated,
          creationParams: <String, dynamic>{
            'width': widget.width,
            'height': widget.height,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Text('ScanView not support the platfrom.');
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
    }
    widget.onCreated(FlutterScanViewController.init(id));
  }
}
