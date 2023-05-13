// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

import 'appConfig.dart';
import 'service/main.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  final String appUrl = AppConfig.h5url;
  late WebViewController? _webViewController;

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
    // Android：当用户使用默认的后退手势时不应该直接跳出App，而是应该拦截此动作并运行 h5 的后退操作
    // 当退无可退时不再响应
    return WillPopScope(
      onWillPop: () async {
        _webViewController?.runJavascript("goback()");
        return false;
      },
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          body: WebView(
            initialUrl: appUrl,
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              _serviceChannel(context),
              _permissionChannel(context),
            },
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              webViewController.loadUrl(appUrl);
              webViewController.clearCache();
            },
            zoomEnabled: false,
          ),
        ),
      ),
    );
  }

  // 创建 JavascriptChannel
  // 预留的调用服务通道（直接发起动作）
  JavascriptChannel _serviceChannel(BuildContext context) => JavascriptChannel(
        name: 'call',
        onMessageReceived: (JavascriptMessage msg) async {
          String mainInfo = msg.message;
          // print(" ======================= ");
          // print(mainInfo);
          // print(" ======================= ");
          // =================== 无参数调用 ===================
          // 后退
          if (mainInfo == "backup" || mainInfo == "done") {
            Navigator.of(context).pop();
          }
          //
          else if (mainInfo == "xxxxxxx") {
          }
          // =================== 带参数调用 ===================
          else {
            List<String> infoArr = mainInfo.split(StaticConfig.argsSpliter);
            String _fnKey = infoArr[0];
            // 短提示
            if (_fnKey == "toast") {
              Toast.show(context, infoArr[1]);
            }
            // 模态提示
            else if (_fnKey == "modalTips") {
              String? res =
                  await ModalTips.show(context, infoArr[1], infoArr[2]);
              _webViewController?.runJavascript("modalTipsCallback('$res')");
            }
            // 模态确认询问
            else if (_fnKey == "modalConfirm") {
              String? res =
                  await ModalConfirm.show(context, infoArr[1], infoArr[2]);
              _webViewController?.runJavascript("modalConfirmCallback('$res')");
            }
            // 展示加载中
            else if (_fnKey == "modalLoading") {
              ModalLoading.show(context, infoArr[1]);
            }
            // 展示模态进度条
            else if (_fnKey == "modalProgress") {
              ModalProgress.show(context, infoArr[1]);
            }
            // 模态进度条值
            else if (_fnKey == "modalProgressAdd") {
              ModalProgress.addstep(double.parse(infoArr[1]));
            }
            // 模态进度条值
            else if (_fnKey == "modalProgressSet") {
              ModalProgress.setstep(double.parse(infoArr[1]));
            }
            // app 更新
            else if (_fnKey == "appUpdate") {
              AppUpdater.updateApp(context, infoArr[1], "fmct.apk");
            }
            // 拨打电话
            else if (_fnKey == "phonecall") {
              PhoneCall.dial(context, infoArr[1]);
            }
            // 在浏览器打开某网址
            else if (_fnKey == "launchInExplorer") {
              LaunchInExplorer.at(context, infoArr[1], false);
            }
            // 在 url_launcher 内嵌浏览器打开某网址
            else if (_fnKey == "launchInnerExplorer") {
              LaunchInExplorer.at(context, infoArr[1], true);
            }
          }
        },
      );

  // 创建 JavascriptChannel
  // 预留的权限请求通道
  JavascriptChannel _permissionChannel(BuildContext context) =>
      JavascriptChannel(
        name: 'requestPermission',
        onMessageReceived: (JavascriptMessage msg) {
          String mainInfo = msg.message;
          // print(" ======================= ");
          // print(mainInfo);
          // print(" ======================= ");
          // 后退
          if (mainInfo == "xxxxxxxxx") {
          } else if (mainInfo == "xxxxs") {}
        },
      );
}