import 'package:flutter_webview_pro/webview_flutter.dart';
import '../appConfig.dart';

class Utils {
  static String getFnName() {
    return StaticConfig.preName;
  }

  static void runChannelJs(
      WebViewController? webViewController, String codeStr) {
    webViewController?.runJavascript("${getFnName()}$codeStr");
  }
}
