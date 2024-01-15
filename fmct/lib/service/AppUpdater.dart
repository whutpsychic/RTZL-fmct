// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:easy_app_installer/easy_app_installer.dart';
import './ModalProgress.dart';
import './Toast.dart';

import '../appConfig.dart';

class AppUpdater {
  static final Uri _url = Uri.parse(StaticConfig.updateAppStoreUrl);

  static Future<void> _launchUrl(BuildContext context) async {
    if (!await launchUrl(_url)) {
      Toast.show(context, "更新失败!");
    }
  }

  static void updateApp(
      BuildContext context, String url, String fileName) async {
    // 如果是苹果，那么跳转至应用商店
    if (Platform.isIOS) {
      _launchUrl(context);
    }
    // 其余按照Android处理
    else {
      ModalProgress.show(context, "正在下载更新...");
      // fileUrl 需替换为指定apk地址
      await EasyAppInstaller.instance.downloadAndInstallApk(
        fileUrl: url,
        fileDirectory: "updateApk",
        fileName: fileName,
        explainContent: "快去开启权限！！！",
        onDownloadingListener: (progress) {
          if (progress < 100) {
            ModalProgress.setstep(progress / 100);
          } else {
            Navigator.of(context).pop();
            Toast.show(context, "下载成功");
          }
        },
        onCancelTagListener: (tag) {
          // 下载失败时
          Navigator.of(context).pop();
          Toast.show(context, "已经是最新版本了");
        },
      );
    }
  }
}
