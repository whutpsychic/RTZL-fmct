// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide LocalStorage;
import 'package:vibration/vibration.dart';

import '../appConfig.dart';
import '../service/main.dart';
import '../main.dart';

// 创建 JavascriptChannel
// 预留的调用服务通道（直接发起动作）
void registerServiceChannel(
    BuildContext context, WebMessagePort port, WebMessage? message) async {
  String? mainInfo = message?.data;
  if (mainInfo == null) {
    return;
  }
  List<String> infoArr = mainInfo.split(StaticConfig.argsSpliter);
  String fnKey = infoArr[0];
  // =================== 无参数调用 ===================
  // flutter 页面后退
  if (fnKey == "backup" || fnKey == "done") {
    Navigator.of(context).pop();
  }
  // 去扫二维码
  else if (fnKey == "scannerQR") {
    String? res = await Scanner.doQRAction(context);
    await port.postMessage(WebMessage(data: "scanner('$res')"));
  }
  // 去扫条形码
  else if (fnKey == "scannerBarcode") {
    String? res = await Scanner.doBarcodeAction(context);
    await port.postMessage(WebMessage(data: "scanner('$res')"));
  }
  // 混合扫码
  else if (fnKey == "scanner") {
    String? res = await Scanner.doAction(context);
    await port.postMessage(WebMessage(data: "scanner('$res')"));
  }
  // 打开 App 设置（权限专用）
  else if (fnKey == "openAppSettings") {
    bool result = await openAppSettings();
    if (!result) {
      ModalTips.show(context, "警告", "无法从您的设备直接打开系统设置，请前往系统设置为应用设定权限。");
    }
  }
  // 去往服务器 IP 设置界面
  else if (fnKey == "ipConfig") {
    appPageKey.currentState?.ipConfig();
  }
  // 检查网络连接类型
  else if (fnKey == "checkNetworkType") {
    String res = await NetworkInfo.checkType();
    await port.postMessage(WebMessage(data: "checkNetworkType('$res')"));
  }
  // 获取当前设备的 safeHeight [top, bottom]
  else if (fnKey == "getSafeHeight") {
    double top = MediaQuery.of(context).padding.top;
    double bottom = MediaQuery.of(context).padding.bottom;
    List<double> res = [top, bottom];
    await port.postMessage(WebMessage(data: "getSafeHeight($res)"));
  }
  // 设置顶部条为深色风格
  else if (fnKey == "setTopbarStyleToDark") {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black, // 设置为黑色
        systemNavigationBarColor: Colors.black, // 设置为黑色
      ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }
  // 设置顶部条为浅色风格
  else if (fnKey == "setTopbarStyleToLight") {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 设置为透明
        systemNavigationBarColor: Colors.transparent, // 设置为透明
      ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
  }
  // 去拍照并返回照片（base64）
  else if (fnKey == "takePhoto") {
    appPageKey.currentState?.takePhoto();
  }
  // 颤动(按键手触觉)
  else if (fnKey == 'heavyImpact') {
    HapticFeedback.heavyImpact();
  }
  // 播放提示音
  else if (fnKey == 'beep') {
    Beep beep = await Beep().init();
    beep.play();
  }
  // 将App设置为全屏渲染(沉浸式)
  else if (fnKey == 'immersed') {
    appPageKey.currentState?.setAppRenderType(true);
  }
  // 将App设置为安全渲染(非沉浸式)
  else if (fnKey == 'unImmersed') {
    appPageKey.currentState?.setAppRenderType(false);
  }
  // =================== 带参数调用 ===================
  else {
    // 短提示
    if (fnKey == "toast") {
      Toast.show(context, infoArr[1]);
    }
    // 模态提示
    else if (fnKey == "modalTips") {
      String? res = await ModalTips.show(context, infoArr[1], infoArr[2]);
      port.postMessage(WebMessage(data: "modalTips('$res')"));
    }
    // 模态确认询问
    else if (fnKey == "modalConfirm") {
      String? res = await ModalConfirm.show(context, infoArr[1], infoArr[2]);
      port.postMessage(WebMessage(data: "modalConfirm('$res')"));
    }
    // 展示加载中
    else if (fnKey == "modalLoading") {
      ModalLoading.show(context, infoArr[1]);
    }
    // 展示模态进度条
    else if (fnKey == "modalProgress") {
      ModalProgress.show(context, infoArr[1]);
    }
    // 模态进度条值
    else if (fnKey == "modalProgressAdd") {
      ModalProgress.addstep(double.parse(infoArr[1]));
    }
    // 模态进度条值
    else if (fnKey == "modalProgressSet") {
      ModalProgress.setstep(double.parse(infoArr[1]));
    }
    // app 更新
    else if (fnKey == "appUpdate") {
      AppUpdater.updateApp(context, infoArr[1], infoArr[2]);
    }
    // 拨打电话
    else if (fnKey == "phonecall") {
      PhoneCall.dial(context, infoArr[1]);
    }
    // 在浏览器打开某网址
    else if (fnKey == "launchInExplorer") {
      LaunchInExplorer.at(context, infoArr[1], false);
    }
    // 在 url_launcher 内嵌浏览器打开某网址
    else if (fnKey == "launchInnerExplorer") {
      LaunchInExplorer.at(context, infoArr[1], true);
    }
    // 写入本地缓存数据
    else if (fnKey == "recordLocal") {
      LocalStorage.setValue(infoArr[1], infoArr[2]);
    }
    // 读取本地缓存数据
    else if (fnKey == "readLocal") {
      String? result = await LocalStorage.getValue(infoArr[1]);
      port.postMessage(WebMessage(data: "readLocal('$result')"));
    }
    // 震动
    else if (fnKey == 'vibrate') {
      bool? hasVibrator = await Vibration.hasVibrator();
      // 有震荡器
      if (hasVibrator != null && hasVibrator) {
        bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
        // 有震幅控制器
        if (hasAmplitudeControl != null && hasAmplitudeControl) {
          String? result = await LocalStorage.getValue(infoArr[1]);
          if (result != null) {
            int amplitude = int.parse(result);
            Vibration.vibrate(amplitude: amplitude);
          } else {
            Vibration.vibrate();
          }
        } else {
          Vibration.vibrate();
        }
      }
    }
    // 即时通知
    else if (fnKey == "notification") {
      // 参数提取
      String title = infoArr[1];
      String content = infoArr[2];

      Notification.show(notification, title, content);
    }
    // 定时通知
    else if (fnKey == "periodNotification") {
      // 参数提取
      String title = infoArr[1];
      String content = infoArr[2];
      int timer = int.parse(infoArr[3]);

      Notification.periodShow(notification, title, content, timer);
    }
  }
}
