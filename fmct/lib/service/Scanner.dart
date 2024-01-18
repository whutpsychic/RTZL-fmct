// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../pages/Scanning.dart';

class Scanner {
  static Future<String?> doQRAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const Scanning(type: ScanType.qr)),
    );
  }

  static Future<String?> doBarcodeAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const Scanning(type: ScanType.barcode)),
    );
  }

  static Future<String?> doAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const Scanning(type: ScanType.mixins)),
    );
  }
}
