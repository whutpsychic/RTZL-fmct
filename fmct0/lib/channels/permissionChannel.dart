// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/main.dart';
import '../App.dart';

// 创建 JavascriptChannel
// 预留的权限请求通道
JavascriptChannel permissionChannel(BuildContext context) => JavascriptChannel(
      name: '${Utils.getFnName()}requestPermission',
      onMessageReceived: (JavascriptMessage msg) async {
        String mainInfo = msg.message;
        // print(" ======================= ");
        // print(mainInfo);
        // print(" ======================= ");
        // 相机/摄像头权限
        if (mainInfo == "camera") {
          PermissionStatus result = await Permission.camera.request();
          Utils.runChannelJs(globalWebViewController, "aprcamera('$result')");
        }
        // 读写权限
        else if (mainInfo == "storage") {
          PermissionStatus result = await Permission.storage.request();
          Utils.runChannelJs(globalWebViewController, "aprstorage('$result')");
        }
      },
    );
