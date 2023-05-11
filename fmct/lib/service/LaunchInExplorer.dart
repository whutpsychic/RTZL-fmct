// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fmct/service/Toast.dart';

class LaunchInExplorer {
  static Future<void> at(BuildContext context, String uri) async {
    Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Toast.show(context, "打开失败!");
    }
  }
}
