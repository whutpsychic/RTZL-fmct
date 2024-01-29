// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../appConfig.dart';

// 创建 JavascriptChannel
// 预留的权限请求通道
void registerPermissionChannel(
    BuildContext context, WebMessagePort port, WebMessage? message) async {
  String? mainInfo = message?.data;
  if (mainInfo == null) {
    return;
  }
  List<String> infoArr = mainInfo.split(StaticConfig.argsSpliter);
  String fnKey = infoArr[0];
  // =================== 无参数调用 ===================
  // 相机/摄像头权限✔
  if (fnKey == "camera") {
    PermissionStatus result = await Permission.camera.request();
    await port.postMessage(WebMessage(data: "aprcamera('$result')"));
  }
  // 读写权限✔
  else if (fnKey == "storage") {
    PermissionStatus result = await Permission.storage.request();
    await port.postMessage(WebMessage(data: "aprstorage('$result')"));
  }
  // 通知权限✔
  else if (fnKey == "notification") {
    PermissionStatus result = await Permission.notification.request();
    await port.postMessage(WebMessage(data: "aprnotification('$result')"));
  }
}
