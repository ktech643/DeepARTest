import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:impekt_deepar/camra_controller.dart';
import 'package:impekt_deepar/impekt_deepar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController cameraController = CameraController(
      deepArKey:
          "8e2d8c59efc7a141b49c2422c0dfedbcf6cacc0e0b540779f45d928ad54718f68ccbd8fd41ac5fb7",
      frameWidth: 720,
      frameHeight: 1080);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Impekt DeepAR"),
        ),
        body: ImpektDeepar(
          cameraController: cameraController,
        ),
      ),
    );
  }
}
