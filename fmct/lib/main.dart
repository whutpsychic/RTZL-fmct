import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide LocalStorage;
import 'package:url_launcher/url_launcher.dart';
import 'package:shake/shake.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import './service/main.dart';
import './h5Channels/main.dart';
import './pages/Ipconfig.dart';
import './pages/CameraTakingPhoto.dart';
import './pages/Welcome.dart';

import './appConfig.dart';

GlobalKey<MyAppState> appPageKey = GlobalKey();

enum ConnectStateType { mobile, wifi, none, unknown }

// 通知实例
Notification notification = Notification();

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

  // 初始化通知模块的服务
  await notification.init();

  // 首次运行，需前往欢迎
  String? isInitLoad = await LocalStorage.getValue('isInitLoad');
  if (isInitLoad == null) {
    await LocalStorage.setValue('isInitLoad', 'true');
    runApp(const MaterialApp(home: Welcome()));
  } else {
    runApp(MaterialApp(home: MyApp(key: appPageKey)));
  }
}

// 主程序
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

  String h5url = '';
  late WebMessagePort flutterPort;
  // 沉浸式渲染控制键
  ValueListenable<bool> immersed = ValueNotifier(true);
  // 当前网络连接情况
  ConnectStateType ctype = ConnectStateType.none;

  @override
  void initState() {
    super.initState();
    _listenNetChange();
    // 仅调试时有的逻辑
    if (kDebugMode) {
      _shakeToConfigureUrl();
    }
    _loadH5();
  }

  void setAppRenderType(bool ifImmersed) {
    setState(() {
      immersed = ValueNotifier(ifImmersed);
    });
  }

  // 摇一摇配置地址
  _shakeToConfigureUrl() {
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

  _loadH5() async {
    String targetUrl = await AppConfig.getH5url();
    setState(() {
      h5url = targetUrl;
    });
  }

  // 监听网络环境变化
  _listenNetChange() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.mobile:
          if (kDebugMode) {
            print("Mobile data connection is being used.");
          }
          ctype = ConnectStateType.mobile;
          break;
        case ConnectivityResult.wifi:
          if (kDebugMode) {
            print("Wi-Fi connection is being used.");
          }
          ctype = ConnectStateType.wifi;
          break;
        case ConnectivityResult.none:
          if (kDebugMode) {
            print("No connection.");
          }
          // 提示没有网络连接
          if (ctype != ConnectStateType.none) {
            Toast.show(context, '您的网络已经断开，将会影响您继续使用App的某些功能，请检查网络连接。');
          }
          ctype = ConnectStateType.none;
          break;
        default:
          ctype = ConnectStateType.unknown;
          if (kDebugMode) {
            print("Unknown connection type.");
          }
      }
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
    flutterPort.postMessage(WebMessage(data: "takePhoto('$result')"));
  }

  // 构建主显示口
  Widget _buildMainView() {
    return Column(
      children: <Widget>[
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
                // _loadH5();
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
                // 加载完毕后记录当前web地址
                if (!(h5url == '')) {
                  setState(() {
                    h5url = url.toString();
                  });
                }
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
                      print(' -------------------------------- from js ');
                      print(message);
                    }

                    // 注册所有服务接口
                    registerServiceChannel(context, port1, message);
                    // 注册权限接口
                    registerPermissionChannel(context, port1, message);
                  });

                  // transfer port2 to the webpage to initialize the communication
                  await controller.postWebMessage(
                      message:
                          WebMessage(data: "initFlutterPort", ports: [port2]),
                      targetOrigin: WebUri("*"));
                }
              },
              onReceivedError: (controller, request, error) {
                if (kDebugMode) {
                  print(" --------------------------------- onReceivedError ");
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
                  print(" --------------------------------- onConsoleMessage ");
                  print(consoleMessage.message);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return h5url == ''
        ? Container()
        : Scaffold(
            body: ValueListenableBuilder(
              valueListenable: immersed,
              builder: (context, state, child) {
                return SafeArea(
                  // 为搭建沉浸式App考虑放开
                  top: !state,
                  // 底部强制安全区
                  bottom: false,
                  child: _buildMainView(),
                );
              },
            ),
          );
  }
}
