import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liveness/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  Uint8List? _cameraImage;
  static const _platform = MethodChannel('SendForProcess');
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

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
      appBar: AppBar(
        title: const Text("Camera Preview"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: _cameraImage != null
            ? Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: effectsList.length,
                        itemBuilder: (context, index) {
                          String data = effectsList[index];
                          bool isSelected = selectedIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                _platform.invokeMethod<Uint8List>(
                                  "changeEffect",
                                  {"effect": data},
                                );
                              },
                              child: Chip(
                                label: Text(
                                  data,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                backgroundColor: selectedIndex == index
                                    ? Colors.lightBlue
                                    : Colors.white54,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: RepaintBoundary(
                      child: Image.memory(
                        _cameraImage!,
                        gaplessPlayback:
                            true, // Prevent flashing between updates
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ],
              )
            : const Text("Waiting for camera..."),
      ),
    );
  }
}
