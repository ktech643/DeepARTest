import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impekt_deepar/camra_controller.dart';
import 'package:impekt_deepar/constants.dart';

class ImpektDeepar extends StatefulWidget {
  List<String> effects = effectsList;

  CameraController cameraController;

  ImpektDeepar({
    Key? key,
    required this.cameraController,
  }) : super(key: key);

  @override
  LivenessWidgetState createState() => LivenessWidgetState();
}

class LivenessWidgetState extends State<ImpektDeepar> {
  late MethodChannel _channel;
  Uint8List? _cameraImage;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _channel = widget.cameraController.channel;
    setState(() {});

    widget.cameraController.initializeLiveness();
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == "updateCameraFrame") {
      setState(() {
        _cameraImage = call.arguments as Uint8List;
      });
      print(_cameraImage.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Effects ListView
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.effects.length,
            itemBuilder: (context, index) {
              String effect = widget.effects[index];
              bool isSelected = selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.cameraController.changeEffect(effect);
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
    );
  }
}
