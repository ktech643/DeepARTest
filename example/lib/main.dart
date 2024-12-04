import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:impekt_deepar/camra_controller.dart';
import 'package:impekt_deepar/constants.dart';

late List<CameraDescription> _cameras;

class Throttler {
  Throttler({required this.milliSeconds});

  final int milliSeconds;

  int? lastActionTime;

  void run(VoidCallback action) {
    if (lastActionTime == null) {
      action();
      lastActionTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      if (DateTime.now().millisecondsSinceEpoch - lastActionTime! >
          (milliSeconds)) {
        action();
        lastActionTime = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraProcessor cameraController;
  late CameraController controller;
  late Throttler throttler;
  late StreamSubscription<int> timer;
  Uint8List? _cameraImage;
  int selectedIndex = 0;

  List<String> effects = effectsList; // Replace with actual effects

  @override
  void initState() {
    super.initState();
    cameraController = CameraProcessor(
        deepArKey:
            "8e2d8c59efc7a141b49c2422c0dfedbcf6cacc0e0b540779f45d928ad54718f68ccbd8fd41ac5fb7",
        frameWidth: 720,
        frameHeight: 1080,
        onCameraFrameUpdate: (data) {
          setState(() {
            _cameraImage = data;
          });
        });
    throttler = Throttler(milliSeconds: 500);

    final cameraDescription = _cameras
        .where(
          (element) => element.lensDirection == CameraLensDirection.front,
        )
        .first;

    controller = CameraController(cameraDescription, ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      //Future.delayed(const Duration(milliseconds: 500));

      // Only open and close camera in iOS for low-tier device
      if (Platform.isIOS) {
        controller.startImageStream((image) async {
          if (Platform.isIOS) {
            try {
              await cameraController.initializeLiveness(
                  bytes: image.planes.first.bytes,
                  bytesPerRow: image.planes.first.bytesPerRow,
                  width: image.width,
                  height: image.height);
            } on PlatformException catch (e) {}
          }
        });
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("impekt DeepAR"),
        ),
        body: Column(
          children: [
            // Effects ListView
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: effects.length,
                itemBuilder: (context, index) {
                  String effect = effects[index];
                  bool isSelected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        cameraController.changeEffect(effect);
                      },
                      child: Chip(
                        label: Text(
                          effect,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black),
                        ),
                        backgroundColor:
                            isSelected ? Colors.lightBlue : Colors.white54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Camera Image Preview
            Expanded(
              child: _cameraImage != null
                  ? RepaintBoundary(
                      child: Image.memory(
                        _cameraImage!,
                        gaplessPlayback: true,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : const Center(child: Text("Waiting for camera...")),
            ),
          ],
        ),
      ),
    );
  }
}
