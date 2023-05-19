// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import './service/main.dart';

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
        title: const Text('Flutter 服务'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton("轻提示", () {
              Toast.show(context, "Hi，短提示在此！");
            }),
            _buildButton('模态提示', () async {
              String? result = await ModalTips.show(context, "title", "desc");
              print(result);
            }),
            _buildButton('模态确认询问', () async {
              String? result =
                  await ModalConfirm.show(context, "title", "desc");
              print(result);
            }),
            _buildButton('模态加载中提示', () async {
              ModalLoading.show(context, "加载中...");
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
              //     "https://github.com/whutpsychic/RTZL-fmct/raw/main/testapk2.apk",
              AppUpdater.updateApp(context,
                  "http://nxbhyt.cn:8280/exam/app/bhyt.apk", "fmct.apk");
            }),
            _buildButton('拨打电话: 139 8888 8888', () async {
              PhoneCall.dial(context, "13988888888");
            }),
            _buildButton('在外部浏览器中打开某网页(百度)', () async {
              LaunchInExplorer.at(context, "https://www.baidu.com", false);
            }),
            _buildButton('在内置浏览器中打开某网页(腾讯)', () async {
              LaunchInExplorer.at(context, "https://www.tencent.com", true);
            }),
            _buildButton('请求照相机权限', () async {
              PermissionStatus result = await Permission.camera.request();
              print(result);
            }),
            _buildButton('请求存储权限', () async {
              PermissionStatus result = await Permission.storage.request();
              print(result);
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
