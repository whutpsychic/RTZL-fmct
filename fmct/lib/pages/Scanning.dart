// ----------------- 扫码页 -----------------
// ----------------- ----------------- -----------------
// ignore_for_file: file_names, use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import '../UIcomponents/ScannerQRView.dart';
import '../UIcomponents/ScannerBarcodeView.dart';
import '../UIcomponents/ScannerView.dart';

// 扫码模式:
// qr: 二维码
// barcode: 条形码
// mixins: 混合扫描
enum ScanType { qr, barcode, mixins }

class Scanning extends StatefulWidget {
  final ScanType type;
  const Scanning({Key? key, required this.type}) : super(key: key);

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  @override
  void initState() {
    super.initState();
    _prepareToGo();
  }

  _prepareToGo() async {
    // 多久后跳转
    const int waiting = 500;
    // qr
    if (widget.type == ScanType.qr) {
      await Future.delayed(const Duration(milliseconds: waiting), () async {
        String? result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ScannerQRView()),
        );
        Navigator.of(context).pop(result);
      });
    }
    // barcode
    if (widget.type == ScanType.barcode) {
      await Future.delayed(const Duration(milliseconds: waiting), () async {
        String? result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ScannerBarcodeView()),
        );
        Navigator.of(context).pop(result);
      });
    }
    // mixins
    if (widget.type == ScanType.mixins) {
      await Future.delayed(const Duration(milliseconds: waiting), () async {
        String? result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ScannerView()),
        );
        Navigator.of(context).pop(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }
}
