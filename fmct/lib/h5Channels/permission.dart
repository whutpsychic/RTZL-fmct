// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../service/main.dart';

const String preName = 'pm_';

// 创建 JavascriptChannel
// 预留的权限请求通道
Future<void> registerPermissionChannel(
    InAppWebViewController controller, BuildContext context) async {
  // =================== 无参数调用 ===================
  // 打开 App 设置（权限专用）
  controller.addJavaScriptHandler(
      handlerName: 'scanner',
      callback: (args) async {
        bool result = await openAppSettings();
        if (!result) {
          ModalTips.show(context, "警告", "无法从您的设备直接打开系统设置，请前往系统设置为应用设定权限。");
        }
      });
  // 相机/摄像头权限
  controller.addJavaScriptHandler(
      handlerName: '${preName}camera',
      callback: (args) async {
        PermissionStatus result = await Permission.camera.request();
        return result;
      });

  // 读写权限
  controller.addJavaScriptHandler(
      handlerName: '${preName}storage',
      callback: (args) async {
        PermissionStatus result = await Permission.storage.request();
        return result;
      });

  // 通知权限
  controller.addJavaScriptHandler(
      handlerName: '${preName}notification',
      callback: (args) async {
        PermissionStatus result = await Permission.notification.request();
        return result;
      });
}
