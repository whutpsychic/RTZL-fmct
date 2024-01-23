// // // ignore_for_file: file_names
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class ScannerBarcodeView extends StatefulWidget {
//   const ScannerBarcodeView({super.key});

//   @override
//   State<ScannerBarcodeView> createState() => _ScannerViewState();
// }

// class _ScannerViewState extends State<ScannerBarcodeView>
//     with SingleTickerProviderStateMixin {
//   // 控制器
//   final MobileScannerController controller = MobileScannerController(
//       torchEnabled: false,
//       // useNewCameraSelector: true,
//       formats: [
//         BarcodeFormat.code128,
//         BarcodeFormat.code39,
//         BarcodeFormat.code93
//       ],
//       facing: CameraFacing.back,
//       detectionSpeed: DetectionSpeed.normal
//       // detectionTimeoutMs: 1000,
//       // returnImage: false,
//       );

//   @override
//   Widget build(BuildContext context) {
//     // 顶部条高度
//     final double topSafeHeight = MediaQuery.of(context).padding.top;
//     final double deviceScreenWidth = MediaQuery.of(context).size.width;
//     const double topBarHeight = 140;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Builder(
//         builder: (context) {
//           return Stack(
//             children: [
//               // 主扫描组件
//               MobileScanner(
//                 onScannerStarted: (arguments) {
//                   setState(() {});
//                 },
//                 controller: controller,
//                 errorBuilder: (context, error, child) {
//                   return Text(error.toString());
//                 },
//                 fit: BoxFit.contain,
//                 onDetect: (barcode) {
//                   controller.stop();
//                   // 扫到码后的动作
//                   Navigator.of(context).pop(barcode.barcodes.first.rawValue);
//                 },
//               ),
//               // 控制条
//               Positioned(
//                 top: 0,
//                 child: Container(
//                   color: const Color.fromRGBO(0, 0, 0, 1),
//                   padding: EdgeInsets.only(top: topSafeHeight, bottom: 20),
//                   width: deviceScreenWidth,
//                   height: topBarHeight,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.of(context).pop(),
//                         child: Container(
//                           alignment: Alignment.center,
//                           width: topBarHeight - 40,
//                           height: topBarHeight,
//                           child: const Icon(
//                             Icons.arrow_back_ios,
//                             color: Colors.white,
//                             size: 24.0,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           controller.toggleTorch();
//                         },
//                         child: Container(
//                           alignment: Alignment.center,
//                           width: topBarHeight - 40,
//                           height: topBarHeight,
//                           child: ValueListenableBuilder(
//                             valueListenable: controller.hasTorchState,
//                             builder: (context, state, child) {
//                               if (state != true) {
//                                 return const SizedBox.shrink();
//                               }
//                               return ValueListenableBuilder<TorchState>(
//                                 valueListenable: controller.torchState,
//                                 builder: (context, state, child) {
//                                   switch (state) {
//                                     case TorchState.off:
//                                       return const Icon(
//                                         Icons.flashlight_off,
//                                         color: Colors.grey,
//                                       );
//                                     case TorchState.on:
//                                       return const Icon(
//                                         Icons.flashlight_on,
//                                         color: Colors.green,
//                                       );
//                                   }
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
