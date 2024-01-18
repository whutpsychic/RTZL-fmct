import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';

import './service/main.dart';
import './h5Channels/main.dart';
import './pages/Ipconfig.dart';
import './pages/CameraTakingPhoto.dart';

import './appConfig.dart';

GlobalKey<MyAppState> appPageKey = GlobalKey();
Future main() async {
  // 初始化必须
  WidgetsFlutterBinding.ensureInitialized();

  // flutter预置的变量
  // kIsWeb: 用于判定当前编译的程序是否是运行在web上的
  // defaultTargetPlatform: 用于判定当前程序运行于哪个平台
  // kDebugMode: 用于判断当前环境是否是以debug模式运行的
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  // 权限获取
  // await Permission.camera.request();
  // await Permission.storage.request();
  // await Permission.microphone.request();

  runApp(MaterialApp(home: MyApp(key: appPageKey)));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // final GlobalKey webViewKey = GlobalKey();
  // controller
  InAppWebViewController? webViewController;
  // webview 设置
  // 全部设置参见: https://pub.dev/documentation/flutter_inappwebview/latest/flutter_inappwebview/InAppWebViewSettings-class.html
  InAppWebViewSettings settings = InAppWebViewSettings(
      // 是否可检查
      isInspectable: kDebugMode,
      // 设置为true可避免h5内的音视频自动播放
      mediaPlaybackRequiresUserGesture: true,
      // 自定义媒体相关
      allowsInlineMediaPlayback: true,
      // 完整允许列表: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy
      iframeAllow: "camera; microphone",
      // Set to true if the <iframe> can activate fullscreen mode by calling the requestFullscreen() method.
      iframeAllowFullscreen: true);

  late String h5url = '';
  late WebMessagePort flutterPort;

  @override
  void initState() {
    super.initState();
    _loadH5();
    _shakeToConfigureUrl();
  }

  // 摇一摇配置地址
  _shakeToConfigureUrl() {
    if (kDebugMode) {
      // 监听摇一摇事件
      ShakeDetector.autoStart(
        onPhoneShake: () async {
          // Do stuff on phone shake
          String? result = await ModalConfirm.show(
              context, "您想要重新配置ip地址吗？", "通过配置 ip 来决定您将要访问的app地址");
          if (result == "true") {
            ipConfig();
          }
        },
        minimumShakeCount: 1,
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 2.7,
      );
    }
  }

  _loadH5() async {
    String targetUrl = await AppConfig.getH5url();
    setState(() {
      h5url = targetUrl;
    });
  }

  // -------------------------- 暴露方法 --------------------------
  // 去地址配置页
  void ipConfig() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Ipconfig()),
    );
    webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(result)),
    );
  }

  // 去拍照取相片
  void takePhoto() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TakingPhoto()),
    );
    flutterPort.postMessage(WebMessage(data: "takePhotoCallback('$result')"));
  }

  @override
  Widget build(BuildContext context) {
    return h5url == ''
        ? Container()
        : Scaffold(
            body: SafeArea(
                // 为搭建沉浸式App考虑放开
                top: true,
                // 强制安全区
                bottom: false,
                child: Column(children: <Widget>[
                  Expanded(
                    child: PopScope(
                      canPop: false,
                      onPopInvoked: (didPop) {
                        if (didPop) {
                          return;
                        }
                        webViewController?.goBack();
                      },
                      child: InAppWebView(
                        // key: webViewKey,
                        initialUrlRequest: URLRequest(url: WebUri(h5url)),
                        initialSettings: settings,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {},
                        onPermissionRequest: (controller, request) async {
                          return PermissionResponse(
                              resources: request.resources,
                              action: PermissionResponseAction.GRANT);
                        },
                        //
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunchUrl(uri)) {
                              // Launch the App
                              await launchUrl(
                                uri,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          // 加载完毕后记录当前web地址
                          setState(() {
                            h5url = url.toString();
                          });
                          // 仅android或者支持创建 web message 通道的平台生效
                          if (defaultTargetPlatform != TargetPlatform.android ||
                              await WebViewFeature.isFeatureSupported(
                                  WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
                            // wait until the page is loaded, and then create the Web Message Channel
                            var webMessageChannel =
                                await controller.createWebMessageChannel();
                            // 主操作端口
                            var port1 = webMessageChannel!.port1;
                            // 传递给web用于交互的端口
                            var port2 = webMessageChannel.port2;

                            // 记录在册
                            setState(() {
                              flutterPort = port1;
                            });
                            // set the web message callback for the port1
                            await port1.setWebMessageCallback((message) async {
                              if (kDebugMode) {
                                print(
                                    ' -------------------------------- from js ');
                                print(message);
                              }

                              // 注册所有服务接口
                              registerServiceChannel(context, port1, message);

                              // when it receives a message from the JavaScript side, respond back with another message.
                              // await port1
                              //     .postMessage(WebMessage(data: "$message and back"));
                            });

                            // transfer port2 to the webpage to initialize the communication
                            await controller.postWebMessage(
                                message: WebMessage(
                                    data: "initFlutterPort", ports: [port2]),
                                targetOrigin: WebUri("*"));
                          }
                        },
                        onReceivedError: (controller, request, error) {
                          if (kDebugMode) {
                            print(
                                " --------------------------------- onReceivedError ");
                            print(error.toString());
                          }
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            // ...
                          }
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {},
                        onConsoleMessage: (controller, consoleMessage) {
                          if (kDebugMode) {
                            print(
                                " --------------------------------- onConsoleMessage ");
                            print(consoleMessage.message);
                          }
                        },
                      ),
                    ),
                  ),
                ])));
  }
}
