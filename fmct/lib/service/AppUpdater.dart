// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:easy_app_installer/easy_app_installer.dart';
import 'package:fmct/service/ModalProgress.dart';
import 'package:fmct/service/Toast.dart';

class AppUpdater {
  static void updateApp(
      BuildContext context, String url, String fileName) async {
    // 如果是苹果，那么跳转至应用商店
    if (Platform.isIOS) {
    }
    // 其余按照Android处理
    else {
      ModalProgress.show(context, "正在下载更新...");
      // fileUrl 需替换为指定apk地址
      await EasyAppInstaller.instance.downloadAndInstallApk(
        // fileUrl:
        //     "https://github.com/whutpsychic/RTZL-fmct/raw/main/testapk2.apk",
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
      );
    }
  }
}
