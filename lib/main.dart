import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late List<CameraDescription> _cameras;

class Throttler {
  final int milliSeconds;
  int? _lastActionTime;

  Throttler({required this.milliSeconds});

  void run(VoidCallback action) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (_lastActionTime == null ||
        currentTime - _lastActionTime! > milliSeconds) {
      action();
      _lastActionTime = currentTime;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Stream',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
      // home: VideoStreamFromBytes(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;
  late Throttler _throttler;
  Uint8List? _cameraImage;
  static const _platform = MethodChannel('SendForProcess');

  @override
  void initState() {
    super.initState();
//    _throttler = Throttler(milliSeconds: 30); // Throttle image stream

    // _initializeCamera();
    _platform.invokeMethod<Uint8List>(
      "checkLiveness",
      {},
    );
    _platform.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == "updateCameraFrame") {
      setState(() {
        _cameraImage = call.arguments as Uint8List;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera Preview")),
      body: Center(
        child: _cameraImage != null
            ? Image.memory(
                _cameraImage!,
                fit: BoxFit.fitHeight,
                height: MediaQuery.of(context).size.height,
              )
            : const Text("Waiting for camera..."),
      ),
    );
  }
}
