// import 'package:flutter/material.dart';
// import 'package:impekt_deepar/camra_controller.dart';
// import 'package:impekt_deepar/impekt_deepar.dart';

// class DeepArScreen extends StatefulWidget {
//   const DeepArScreen({Key? key}) : super(key: key);

//   @override
//   _DeepArScreenState createState() => _DeepArScreenState();
// }

// class _DeepArScreenState extends State<DeepArScreen> {
//   ARCameraController cameraController = ARCameraController(
//       deepArKey:
//           "8e2d8c59efc7a141b49c2422c0dfedbcf6cacc0e0b540779f45d928ad54718f68ccbd8fd41ac5fb7",
//       frameWidth: 720,
//       frameHeight: 1080);
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Impekt DeepAR"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.close),
//             onPressed: () async {
//               // Trigger the dispose callback via the controller

//               await cameraController.disposeCamera();
//               Navigator.of(context).pop();
//             },
//           ),
//           // IconButton(
//           //   icon: Icon(Icons.start),
//           //   onPressed: () {
//           //     // Trigger the dispose callback via the controller

//           //     cameraController.startCamera();
//           //   },
//           // ),
//         ],
//       ),
//       body: ImpektDeepar(
//         cameraController: cameraController,
//       ),
//     );
//   }
// }
