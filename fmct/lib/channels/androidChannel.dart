// ignore_for_file: file_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

import '../appConfig.dart';
import '../utils/main.dart';

// 创建 JavascriptChannel
// 预留的 android 的服务调用通道
JavascriptChannel setAndroidChannel(BuildContext context) => JavascriptChannel(
      name: '${Utils.getFnName()}android',
      onMessageReceived: (JavascriptMessage msg) async {
        String mainInfo = msg.message;
        // print(" ======================= ");
        // print(mainInfo);
        // print(" ======================= ");
        List<String> infoArr = mainInfo.split(StaticConfig.argsSpliter);
        String _fnKey = infoArr[0];
        // 原生提示
        if (_fnKey == "toast") {
          print("====================================android");
        }
      },
    );
