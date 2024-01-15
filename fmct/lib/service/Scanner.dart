// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../UIcomponents/ScannerQRView.dart';
import '../UIcomponents/ScannerBarcodeView.dart';
import '../UIcomponents/ScannerView.dart';

class Scanner {
  static Future<String?> doQRAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScannerQRView()),
    );
  }

  static Future<String?> doBarcodeAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScannerBarcodeView()),
    );
  }

  static Future<String?> doAction(BuildContext context) async {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScannerView()),
    );
  }
}
