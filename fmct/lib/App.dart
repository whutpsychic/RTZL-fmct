// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

import 'appConfig.dart';
import './utils/main.dart';

import './channels/main.dart';

late WebViewController? globalWebViewController;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  final String appUrl = AppConfig.h5url;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _runJS(String codeStr) {
    globalWebViewController?.runJavascript("${Utils.getFnName()}$codeStr");
  }

  @override
  Widget build(BuildContext context) {
    // Android：当用户使用默认的后退手势时不应该直接跳出App，而是应该拦截此动作并运行 h5 的后退操作
    // 当退无可退时不再响应
    return WillPopScope(
      onWillPop: () async {
        _runJS("goback()");
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: true,
          child: WebView(
            initialUrl: appUrl,
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>{
              // 服务通道
              serviceChannel(context),
              // 权限通道
              permissionChannel(context),
              // 安卓原生服务通道
              setAndroidChannel(context),
            },
            onWebViewCreated: (WebViewController webViewController) {
              globalWebViewController = webViewController;
              webViewController.loadUrl(appUrl);
              webViewController.clearCache();
            },
            zoomEnabled: false,
          ),
        ),
      ),
    );
  }
}
