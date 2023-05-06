// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ModalLoading {
  static Future show(BuildContext context) async {
    if (Platform.isAndroid) {
      // print('当前运行的平台是 Android');
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text("加载中..."),
          content: SizedBox(
            width: 100,
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else if (Platform.isIOS) {
      // print('当前运行的平台是 iOS');
      return showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => const CupertinoAlertDialog(
          title: Text("加载中..."),
          content: SizedBox(
            width: 100,
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else if (Platform.isWindows) {
      print('当前运行的平台是 Windows');
    } else if (Platform.isMacOS) {
      print('当前运行的平台是 macOS');
    } else if (Platform.isLinux) {
      print('当前运行的平台是 Linux');
    } else {
      print('当前运行的平台未知');
    }
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
