// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:fmct/components/ModalConfirm.dart';
import 'package:fmct/components/ModalTips.dart';
import 'package:fmct/components/ModalLoading.dart';
import 'package:fmct/components/Toast.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  @override
  void initState() {
    super.initState();
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
            _buildButton('模态加载中提示', () {
              ModalLoading.show(context);
            }),
            _buildButton('模态进度条信息', () {}),
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

  @override
  void dispose() {
    super.dispose();
  }
}
