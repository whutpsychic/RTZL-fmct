// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ModalTips {
  static Future show(BuildContext context, String title, String desc) async {
    if (Platform.isIOS) {
      // print('当前运行的平台是 iOS');
      return showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(desc),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as deletion, and turns
              /// the action's text color to red.
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('好'),
            ),
          ],
        ),
      );
    }
    // 其余平台一律按 Android 处理
    else {
      // print('当前运行的平台是 Android');
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(desc),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}
