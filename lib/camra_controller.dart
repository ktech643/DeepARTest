import 'dart:typed_data';
import 'package:flutter/services.dart';

class CameraController {
  late MethodChannel channel = MethodChannel("impekt_deepar");
  final String deepArKey;
  int? frameWidth = 720;
  int? frameHeight = 1080;

  CameraController(
      {required this.deepArKey, this.frameWidth, this.frameHeight});

  // Initialize liveness detection
  Future<void> initializeLiveness() async {
    //channel = MethodChannel("impekt_deepar");
    try {
      await channel.invokeMethod("checkLiveness",
          {"key": deepArKey, "width": frameWidth, "height": frameHeight});
    } on PlatformException catch (e) {
      print("Error initializing liveness: ${e.message}");
    }
  }

  // Start Camera
  Future<void> startCamera() async {
    try {
      await initializeLiveness();
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
