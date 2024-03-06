// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide LocalStorage;
import 'package:vibration/vibration.dart';

import '../service/main.dart';
import '../main.dart';

// 创建 JavascriptChannel
// 预留的调用服务通道（直接发起动作）
Future<void> registerServiceChannel(
    InAppWebViewController controller, BuildContext context) async {
  // =================== 无参数调用 ===================
  // flutter 页面后退/完成动作（后退）
  controller.addJavaScriptHandler(
      handlerName: 'backup',
      callback: (List<dynamic> args) {
        Navigator.of(context).pop();
      });
  controller.addJavaScriptHandler(
      handlerName: 'done',
      callback: (List<dynamic> args) {
        Navigator.of(context).pop();
      });
  // 去扫二维码
  controller.addJavaScriptHandler(
      handlerName: 'scannerQR',
      callback: (List<dynamic> args) async {
        String? res = await Scanner.doQRAction(context);
        return res;
      });
  // 去扫条形码
  controller.addJavaScriptHandler(
      handlerName: 'scannerBarcode',
      callback: (List<dynamic> args) async {
        String? res = await Scanner.doBarcodeAction(context);
        return res;
      });
  // 混合扫码
  controller.addJavaScriptHandler(
      handlerName: 'scanner',
      callback: (List<dynamic> args) async {
        String? res = await Scanner.doAction(context);
        return res;
      });
  // 去往服务器 IP 设置界面
  controller.addJavaScriptHandler(
      handlerName: 'ipConfig',
      callback: (List<dynamic> args) {
        appPageKey.currentState?.ipConfig();
      });
  // 检查网络连接类型
  controller.addJavaScriptHandler(
      handlerName: 'checkNetworkType',
      callback: (List<dynamic> args) async {
        String res = await NetworkInfo.checkType();
        return res;
      });
  // 获取当前设备的 safeHeight [top, bottom]
  controller.addJavaScriptHandler(
      handlerName: 'getSafeHeight',
      callback: (List<dynamic> args) {
        double top = MediaQuery.of(context).padding.top;
        double bottom = MediaQuery.of(context).padding.bottom;
        List<double> res = [top, bottom];
        return res;
      });
  // 设置顶部条为深色风格
  controller.addJavaScriptHandler(
      handlerName: 'setTopbarStyleToDark',
      callback: (List<dynamic> args) {
        if (Platform.isAndroid) {
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.black, // 设置为黑色
            systemNavigationBarColor: Colors.black, // 设置为黑色
          ));
        } else if (Platform.isIOS) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        }
      });
  // 设置顶部条为浅色风格
  controller.addJavaScriptHandler(
      handlerName: 'setTopbarStyleToLight',
      callback: (List<dynamic> args) {
        if (Platform.isAndroid) {
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // 设置为透明
            systemNavigationBarColor: Colors.transparent, // 设置为透明
          ));
        } else if (Platform.isIOS) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
        }
      });
  // 去拍照并返回照片（base64）
  controller.addJavaScriptHandler(
      handlerName: 'takePhoto',
      callback: (List<dynamic> args) async {
        return appPageKey.currentState?.takePhoto();
      });
  // 颤动(按键手触觉)
  controller.addJavaScriptHandler(
      handlerName: 'heavyImpact',
      callback: (List<dynamic> args) {
        HapticFeedback.heavyImpact();
      });
  // 播放提示音
  controller.addJavaScriptHandler(
      handlerName: 'beep',
      callback: (List<dynamic> args) async {
        Beep beep = await Beep().init();
        beep.play();
      });
  // 将App设置为全屏渲染(沉浸式)
  controller.addJavaScriptHandler(
      handlerName: 'immersed',
      callback: (List<dynamic> args) {
        appPageKey.currentState?.setAppRenderType(true);
      });
  // 将App设置为安全渲染(非沉浸式)
  controller.addJavaScriptHandler(
      handlerName: 'unImmersed',
      callback: (List<dynamic> args) {
        appPageKey.currentState?.setAppRenderType(false);
      });
  // 强制横屏
  controller.addJavaScriptHandler(
      handlerName: 'screenHorizontal',
      callback: (List<dynamic> args) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      });
  // 强制竖屏
  controller.addJavaScriptHandler(
      handlerName: 'screenVertical',
      callback: (List<dynamic> args) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      });
  // 自由适应
  controller.addJavaScriptHandler(
      handlerName: 'screenFree',
      callback: (List<dynamic> args) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      });
  // =================== 带参数调用 ===================
  // 短提示
  controller.addJavaScriptHandler(
      handlerName: 'toast',
      callback: (List<dynamic> args) {
        Toast.show(context, args[0]);
      });
  // 模态提示
  controller.addJavaScriptHandler(
      handlerName: 'modalTips',
      callback: (List<dynamic> args) async {
        String res = await ModalTips.show(context, args[0], args[1]);
        return res;
      });

  // 模态确认询问
  controller.addJavaScriptHandler(
      handlerName: 'modalConfirm',
      callback: (List<dynamic> args) async {
        String res = await ModalConfirm.show(context, args[0], args[1]);
        return res;
      });

  // 展示加载中
  controller.addJavaScriptHandler(
      handlerName: 'modalLoading',
      callback: (List<dynamic> args) {
        ModalLoading.show(context, args[0]);
      });

  // 展示模态进度条
  controller.addJavaScriptHandler(
      handlerName: 'modalProgress',
      callback: (List<dynamic> args) {
        ModalProgress.show(context, args[0]);
      });

  // 模态进度条值
  controller.addJavaScriptHandler(
      handlerName: 'modalProgressAdd',
      callback: (List<dynamic> args) {
        if (args[0] is String) {
          ModalProgress.addstep(double.parse(args[0]));
        } else if (args[0] is double) {
          ModalProgress.addstep(args[0]);
        } else if (args[0] is int) {
          ModalProgress.addstep(args[0].toDouble());
        }
      });

  // 模态进度条值
  controller.addJavaScriptHandler(
      handlerName: 'modalProgressSet',
      callback: (List<dynamic> args) {
        if (args[0] is String) {
          ModalProgress.setstep(double.parse(args[0]));
        } else if (args[0] is double) {
          ModalProgress.setstep(args[0]);
        } else if (args[0] is int) {
          ModalProgress.setstep(args[0].toDouble());
        }
      });

  // app 更新
  controller.addJavaScriptHandler(
      handlerName: 'appUpdate',
      callback: (List<dynamic> args) {
        AppUpdater.updateApp(context, args[0], args[1]);
      });

  // 拨打电话
  controller.addJavaScriptHandler(
      handlerName: 'phonecall',
      callback: (List<dynamic> args) {
        PhoneCall.dial(context, args[0]);
      });

  // 在手机浏览器打开某网址
  controller.addJavaScriptHandler(
      handlerName: 'launchInExplorer',
      callback: (List<dynamic> args) {
        LaunchInExplorer.at(context, args[0], false);
      });

  // 在 url_launcher 内嵌浏览器打开某网址
  controller.addJavaScriptHandler(
      handlerName: 'launchInnerExplorer',
      callback: (List<dynamic> args) {
        LaunchInExplorer.at(context, args[0], true);
      });

  // 写入本地缓存数据
  controller.addJavaScriptHandler(
      handlerName: 'recordLocal',
      callback: (List<dynamic> args) {
        LocalStorage.setValue(args[0], args[1]);
      });

  // 读取本地缓存数据
  controller.addJavaScriptHandler(
      handlerName: 'readLocal',
      callback: (List<dynamic> args) async {
        String? result = await LocalStorage.getValue(args[0]);
        return result;
      });

  // 震动
  controller.addJavaScriptHandler(
      handlerName: 'vibrate',
      callback: (List<dynamic> args) async {
        bool? hasVibrator = await Vibration.hasVibrator();
        // 有震荡器
        if (hasVibrator != null && hasVibrator) {
          bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
          // 有震幅控制器
          if (hasAmplitudeControl != null && hasAmplitudeControl) {
            String? result = await LocalStorage.getValue(args[0]);
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
      });

  // 即时通知
  controller.addJavaScriptHandler(
      handlerName: 'notification',
      callback: (List<dynamic> args) {
        // 参数提取
        String title = args[0];
        String content = args[1];

        Notification.show(notification, title, content);
      });

  // 定时通知
  controller.addJavaScriptHandler(
      handlerName: 'periodNotification',
      callback: (List<dynamic> args) {
        // 参数提取
        String title = args[0];
        String content = args[1];
        int timer = int.parse(args[3]);

        Notification.periodShow(notification, title, content, timer);
      });
}
