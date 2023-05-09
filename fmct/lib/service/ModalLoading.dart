// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ModalLoading {
  static Future show(BuildContext context) async {
    if (Platform.isIOS) {
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
    }
    // 其余平台一律按 Android 处理
    else {
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
    }
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
