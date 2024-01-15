import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import './appConfig.dart';

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
  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  @override
  void initState() {
    super.initState();
    _loadH5();
  }

  _loadH5() async {
    String targetUrl = await AppConfig.getH5url();
    setState(() {
      h5url = targetUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return h5url == ''
        ? Container()
        : Scaffold(
            body: SafeArea(
                child: Column(children: <Widget>[
            Expanded(
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
                shouldOverrideUrlLoading: (controller, navigationAction) async {
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
                  setState(() {
                    h5url = url.toString();
                  });
                  if (defaultTargetPlatform != TargetPlatform.android ||
                      await WebViewFeature.isFeatureSupported(
                          WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
                    // wait until the page is loaded, and then create the Web Message Channel
                    var webMessageChannel =
                        await controller.createWebMessageChannel();
                    var port1 = webMessageChannel!.port1;
                    print(
                        '-------------------------------------------webMessageChannel');
                    print(webMessageChannel.id);

                    // set the web message callback for the port1
                    await port1.setWebMessageCallback((message) async {
                      print(
                          "Message coming from the JavaScript side: $message");
                      // when it receives a message from the JavaScript side, respond back with another message.
                      // await port1.postMessage(
                      //     WebMessage(data: message! + " and back"));
                    });
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
                onUpdateVisitedHistory: (controller, url, androidIsReload) {},
                onConsoleMessage: (controller, consoleMessage) {
                  if (kDebugMode) {
                    print(
                        " --------------------------------- onConsoleMessage ");
                    print(consoleMessage);
                  }
                },
              ),
            ),
          ])));
  }
}
