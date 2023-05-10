// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fmct/service/AppUpdater.dart';
import 'package:fmct/service/ModalConfirm.dart';
import 'package:fmct/service/ModalTips.dart';
import 'package:fmct/service/ModalLoading.dart';
import 'package:fmct/service/ModalProgress.dart';
import 'package:fmct/service/Toast.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('fmct'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton("轻提示", () {
              Toast.show(context, "Hi，短提示在此！");
            }),
            _buildButton('模态提示', () async {
              await ModalTips.show(context, "title", "desc");
            }),
            _buildButton('模态确认询问', () async {
              String? result =
                  await ModalConfirm.show(context, "title", "desc");
              print(result);
            }),
            _buildButton('模态加载中提示', () async {
              ModalLoading.show(context);
              await Future.delayed(const Duration(seconds: 3));
              ModalLoading.hide(context);
            }),
            _buildButton('模态进度条信息', () async {
              ModalProgress.show(context, "加载中...");
              timer = Timer.periodic(const Duration(seconds: 1),
                  (Timer t) => ModalProgress.addstep(0.2));

              await Future.delayed(const Duration(seconds: 6));
              ModalProgress.hide(context);
              timer?.cancel();
            }),
            _buildButton('App 更新', () async {
              AppUpdater.updateApp(context,
                  "http://nxbhyt.cn:8280/exam/app/bhyt.apk", "fmct.apk");
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Function function) {
    return MaterialButton(
      color: Colors.blue,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {
        function();
      },
    );
  }
}
