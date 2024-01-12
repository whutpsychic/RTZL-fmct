// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:shake/shake.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import './UIcomponents/NoNetwork.dart';

import 'appConfig.dart';
import './utils/main.dart';
import './service/main.dart';

import 'h5Channels/main.dart';
import './pages/Ipconfig.dart';
import './pages/CameraTakingPhoto.dart';

late final WebViewController globalWebViewController;

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  String _appUrl = "";

  void _initWebviewController() {
    final ServiceChannal serviceChannal = ServiceChannal(context);

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..enableZoom(false)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (Configure.debugging) {
              debugPrint('WebView is loading (progress : $progress%)');
            }
          },
          onPageStarted: (String url) {
            if (Configure.debugging) {
              debugPrint('Page started loading: $url');
            }
          },
          onPageFinished: (String url) {
            if (Configure.debugging) {
              debugPrint('Page finished loading: $url');
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (Configure.debugging) {
              debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // 禁止去往youtube
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            if (Configure.debugging) {
              debugPrint('allowing navigation to ${request.url}');
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (Configure.debugging) {
              debugPrint('url change to ${change.url}');
            }
          },
        ),
      )
      // 插入预留通道
      ..addJavaScriptChannel(
        ServiceChannal.name,
        onMessageReceived: serviceChannal.onMessageReceived,
      )
      ..loadRequest(Uri.parse(_appUrl));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features
    globalWebViewController = controller;
  }

  @override
  void initState() {
    super.initState();
    if (Configure.debugging) {
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
    AppConfig.getH5url().then((res) {
      setState(() {
        _appUrl = res;
      });
      _initWebviewController();
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
    // globalWebViewController?.loadUrl(result);
    globalWebViewController.loadRequest(Uri.parse(result));
  }

  // 去拍照取相片
  void takePhoto() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TakingPhoto()),
    );
    Utils.runChannelJs(globalWebViewController, "takePhotoCallback('$result')");
  }

  @override
  Widget build(BuildContext context) {
    // Android：当用户使用默认的后退手势时不应该直接跳出App，而是应该拦截此动作并运行 h5 的后退操作
    // 当退无可退时不再响应
    return _appUrl == ""
        ? Container()
        : PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) {
                return;
              }
              // Utils.runChannelJs(globalWebViewController, "goback()");
              globalWebViewController.goBack();
            },
            child: Scaffold(
              body: SafeArea(
                top: false,
                bottom: false,
                child: ConnectivityWidgetWrapper(
                  disableInteraction: false,
                  offlineWidget: const NoNetwork(),
                  child: WebViewWidget(
                    controller: globalWebViewController,
                    // initialUrl: _appUrl,
                    // javascriptMode: JavascriptMode.unrestricted,
                    // javascriptChannels: <JavascriptChannel>{
                    //   // 服务通道
                    //   serviceChannel(context),
                    //   // 权限通道
                    //   permissionChannel(context),
                    //   // 安卓原生服务通道
                    //   setAndroidChannel(context),
                    // },
                    // onWebViewCreated:
                    //     (WebViewController webViewController) async {
                    //   // final String appUrl = await AppConfig.getH5url();
                    //   globalWebViewController = webViewController;
                    //   webViewController.loadUrl(_appUrl);
                    //   webViewController.clearCache();
                    // },
                    // zoomEnabled: false,
                  ),
                ),
              ),
            ),
          );
  }
}
