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
            javascriptChannels: <JavascriptChannel>[
              _serviceChannel(context),
              _permissionChannel(context),
            ].toSet(),
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
        onMessageReceived: (JavascriptMessage msg) {
          String mainInfo = msg.message;
          // print(" ======================= ");
          // print(mainInfo);
          // print(" ======================= ");
          // =================== 无参数调用 ===================
          // 后退
          if (mainInfo == "backup") {
            Navigator.of(context).pop();
          }
          //
          else if (mainInfo == "toast") {
          }
          // =================== 带参数调用 ===================
          else {
            List<String> infoArr = mainInfo.split(StaticConfig.argsSpliter);
            String _fnKey = infoArr[0];
            if (_fnKey == "toast") {
              Toast.show(context, infoArr[1]);
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
          if (mainInfo == "backup") {
            Navigator.of(context).pop();
          } else if (mainInfo == "xxxxs") {
            Navigator.of(context).pop();
          }
        },
      );
}
