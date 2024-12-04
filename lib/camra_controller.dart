import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CameraProcessor {
  late MethodChannel channel;
  final String deepArKey;
  final Function(Uint8List) onCameraFrameUpdate;
  int? frameWidth;
  int? frameHeight;

  CameraProcessor({
    required this.deepArKey,
    this.frameWidth = 720,
    this.frameHeight = 1080,
    required this.onCameraFrameUpdate,
  }) {
    channel = MethodChannel("impekt_deepar");

    // Ensure the handler is set after Flutter binding is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMethodCallHandler();
      initialize();
    });
  }

  void _setupMethodCallHandler() {
    channel.setMethodCallHandler((call) async {
      if (call.method == "receiveProcessedFrame") {
        Uint8List cameraFrame = call.arguments as Uint8List;
        onCameraFrameUpdate(cameraFrame); // Notify via the callback
      }
    });
  }

  Future<void> initializeLiveness({
    required Uint8List bytes,
    required int height,
    required int width,
    required int bytesPerRow,
  }) async {
    try {
      await channel.invokeMethod("sendFrameForProcess", {
        'platforms': bytes,
        'height': height,
        'width': width,
        "bytesPerRow": bytesPerRow,
      });
    } on PlatformException catch (e) {}
  }

  Future<void> initialize() async {
    try {
      await channel.invokeMethod("initialize", {
        "key": deepArKey,
        "width": frameWidth,
        "height": frameHeight,
      });
    } on PlatformException catch (e) {}
  }

  Future<void> startCamera() async {
    try {
      await channel.invokeMethod("startCamera");
    } on PlatformException catch (e) {}
  }

  Future<void> disposeCamera() async {
    try {
      await channel.invokeMethod("disposeCamera");
    } on PlatformException catch (e) {}
  }

  Future<void> changeEffect(String effect) async {
    try {
      await channel.invokeMethod("changeEffect", {"effect": effect});
    } on PlatformException catch (e) {}
  }
}
