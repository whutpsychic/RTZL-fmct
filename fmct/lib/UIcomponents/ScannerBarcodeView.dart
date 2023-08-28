// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerBarcodeView extends StatefulWidget {
  const ScannerBarcodeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerBarcodeView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey();

  // 开灯
  bool _openingLight = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeHeight = MediaQuery.of(context).padding.top;
    final double deviceScreenWidth = MediaQuery.of(context).size.width;
    const double topBarHeight = 100;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            _buildScannerView(context),
            Positioned(
              top: 0,
              child: Container(
                color: const Color.fromRGBO(0, 0, 0, 1),
                padding: EdgeInsets.only(top: topSafeHeight, bottom: 20),
                width: deviceScreenWidth,
                height: topBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        alignment: Alignment.center,
                        width: topBarHeight - 40,
                        height: topBarHeight,
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _openingLight = !_openingLight;
                        });
                        controller?.toggleFlash();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: topBarHeight - 40,
                        height: topBarHeight,
                        child: Icon(
                          Icons.flashlight_on,
                          color: _openingLight ? Colors.green : Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 500.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: const <BarcodeFormat>[
        BarcodeFormat.codabar,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
      ],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutWidth: scanArea,
        cutOutHeight: 100,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((Barcode scanData) async {
      await controller.pauseCamera();
      Navigator.of(context).pop(scanData.code);
    });
    // 暂停修复
    controller.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
