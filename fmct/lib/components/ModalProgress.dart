// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

GlobalKey<_ProgressIndicatorState> key = GlobalKey();

class ModalProgress {
  static void addstep(double x) {
    key.currentState?.addstep(x);
  }

  static Future show(BuildContext context) async {
    if (Platform.isAndroid) {
      // print('当前运行的平台是 Android');
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("加载中..."),
          content: SizedBox(
            height: 60,
            child: Center(
              // child: LinearProgressIndicator(value: value),
              child: ProgressIndicatorComponent(key: key),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      key.currentState?.clear();
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

class ProgressIndicatorComponent extends StatefulWidget {
  const ProgressIndicatorComponent({super.key});

  @override
  State<ProgressIndicatorComponent> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicatorComponent>
    with TickerProviderStateMixin {
  late AnimationController controller;
  double _percent = 0.0;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addstep(double x) {
    _percent += x;
    controller.animateTo(_percent);
  }

  void clear() {
    _percent = 0;
    controller.animateTo(_percent);
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: controller.value,
    );
  }
}
