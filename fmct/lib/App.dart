// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:shake/shake.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import './UIcomponents/NoNetwork.dart';

import 'appConfig.dart';
import './utils/main.dart';
import './service/main.dart';

import 'h5Channels/main.dart';
import './pages/Ipconfig.dart';

late WebViewController? globalWebViewController;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  String _appUrl = "";

  @override
  void initState() {
    super.initState();
    if (Configure.debugging) {
      // 监听摇一摇事件
      ShakeDetector detector = ShakeDetector.autoStart(
        onPhoneShake: () async {
          String? result = await ModalConfirm.show(
              context, "您想要重新配置ip地址吗？", "通过配置 ip 来决定您将要访问的app地址");
          if (result == "true") {
            ipConfig();
          }
          // Do stuff on phone shake
        },
        minimumShakeCount: 1,
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.7,
      );
    }
    AppConfig.getH5url().then((res) {
      setState(() {
        _appUrl = res;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 去地址配置页
  void ipConfig() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Ipconfig()),
    );
    globalWebViewController?.loadUrl(result);
  }

  @override
  Widget build(BuildContext context) {
    // Android：当用户使用默认的后退手势时不应该直接跳出App，而是应该拦截此动作并运行 h5 的后退操作
    // 当退无可退时不再响应
    return _appUrl == ""
        ? Container()
        : WillPopScope(
            onWillPop: () async {
              Utils.runChannelJs(globalWebViewController, "goback()");
              return false;
            },
            child: Scaffold(
              body: SafeArea(
                top: true,
                bottom: true,
                child: ConnectivityWidgetWrapper(
                  disableInteraction: false,
                  offlineWidget: const NoNetwork(),
                  child: WebView(
                    initialUrl: _appUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: <JavascriptChannel>{
                      // 服务通道
                      serviceChannel(context),
                      // 权限通道
                      permissionChannel(context),
                      // 安卓原生服务通道
                      setAndroidChannel(context),
                    },
                    onWebViewCreated:
                        (WebViewController webViewController) async {
                      // final String appUrl = await AppConfig.getH5url();
                      globalWebViewController = webViewController;
                      webViewController.loadUrl(_appUrl);
                      webViewController.clearCache();
                    },
                    zoomEnabled: false,
                  ),
                ),
              ),
            ),
          );
  }
}
