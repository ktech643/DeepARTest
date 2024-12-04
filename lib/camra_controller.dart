import 'dart:typed_data';
import 'package:flutter/services.dart';

class ARCameraController {
  late MethodChannel channel = MethodChannel("impekt_deepar");
  final String deepArKey;
  int? frameWidth = 720;
  int? frameHeight = 1080;
  Function(Uint8List)? onCameraFrameUpdate;

  ARCameraController(
      {required this.deepArKey, this.frameWidth, this.frameHeight});

  // Initialize liveness detection
  Future<void> initializeLiveness({required bytes}) async {
    //channel = MethodChannel("impekt_deepar");
    try {
      await channel.invokeMethod("checkLiveness", {
        "key": deepArKey,
        "width": frameWidth,
        "height": frameHeight,
        "bytes": bytes
      });
      callBack();
    } on PlatformException catch (e) {
      print("Error initializing liveness: ${e.message}");
    }
  }

  Future<Uint8List?> callBack() async {
    // Set up the method call handler

    channel.setMethodCallHandler((call) async {
      if (call.method == "updateCameraFrame") {
        Uint8List cameraFrame = call.arguments as Uint8List;
        onCameraFrameUpdate?.call(cameraFrame); // Notify the listener
        // return cameraFrame;
      }
    });
  }

  // Start Camera
  Future<void> startCamera() async {
    try {
      // await initializeLiveness();
    } on PlatformException catch (e) {
      print("Error starting camera: ${e.message}");
    }
  }

  // Dispose Camera
  Future<void> disposeCamera() async {
    try {
      await channel.invokeMethod("disposeCamera");
    } on PlatformException catch (e) {
      print("Error disposing camera: ${e.message}");
    }
  }

  // Change Effect
  Future<void> changeEffect(String effect) async {
    try {
      await channel.invokeMethod("changeEffect", {"effect": effect});
    } on PlatformException catch (e) {
      print("Error changing effect: ${e.message}");
    }
  }

  Future<Uint8List?> onMethodCall(MethodCall call) async {
    Uint8List? bytes;
    if (call.method == "updateCameraFrame") {
      bytes = call.arguments as Uint8List;
      return bytes;
    }
  }
}
