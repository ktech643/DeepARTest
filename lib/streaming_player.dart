// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Stream from Bytes',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const VideoStreamFromBytes(),
//     );
//   }
// }

// class VideoStreamFromBytes extends StatefulWidget {
//   const VideoStreamFromBytes({Key? key}) : super(key: key);

//   @override
//   _VideoStreamFromBytesState createState() => _VideoStreamFromBytesState();
// }

// class _VideoStreamFromBytesState extends State<VideoStreamFromBytes> {
//   static const MethodChannel _platform = MethodChannel('SendForProcess');
//   ui.Image? _currentFrame;

//   @override
//   void initState() {
//     super.initState();

//     // Listen for frames from the native side.
//     _platform.setMethodCallHandler((call) async {
//       if (call.method == "updateCameraFrame") {
//         final bytes = call.arguments as Uint8List;
//         _updateFrame(bytes);
//       }
//     });
//   }

//   /// Updates the frame by decoding image bytes.
//   Future<void> _updateFrame(Uint8List bytes) async {
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frame = await codec.getNextFrame();
//     setState(() {
//       _currentFrame = frame.image;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Video Stream from Bytes')),
//       body: Center(
//         child: _currentFrame != null
//             ? CustomPaint(
//                 painter: _VideoPainter(_currentFrame!),
//                 size: MediaQuery.of(context).size,
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }

// class _VideoPainter extends CustomPainter {
//   final ui.Image frame;

//   _VideoPainter(this.frame);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();
//     final src =
//         Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble());
//     final dst = Rect.fromLTWH(0, 0, size.width, size.height);

//     canvas.drawImageRect(frame, src, dst, paint);
//   }

//   @override
//   bool shouldRepaint(covariant _VideoPainter oldDelegate) {
//     return oldDelegate.frame != frame;
//   }
// }
