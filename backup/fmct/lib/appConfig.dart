// ignore_for_file: file_names
// ================ 控制阀文件 ================
// 调试模式变量使用 flutter 预置的变量 kDebugMode
// 会打开一些本不可被修改的设置途径
// ✔ 摇一摇设置 ip
// ==========================================
import './service/LocalStorage.dart';

enum AppMode { prodution, dev }

class Configure {
  // =================== dev 本地开发模式 ===================
  // 连接到本地开发环境
  // =================== production 产品模式 ===================
  // 连接到正式环境
  static const AppMode appMode = AppMode.dev;
}

// 最终控制结果
class AppConfig {
  // 对接的h5地址
  // 以本地缓存为主，若是第一次运行，则根据运行模式指向预设的地址
  static Future<String> getH5url() async {
    String? url = await LocalStorage.getValue("serverUrl");
    if (url != null) {
      return url;
    }

    switch (Configure.appMode) {
      case AppMode.prodution:
        return StaticConfig.productionH5url;
      case AppMode.dev:
        return StaticConfig.devH5url;
      default:
        return StaticConfig.productionH5url;
    }
  }

  // 默认的 h5 地址
  static String h5url = Configure.appMode == AppMode.prodution
      ? StaticConfig.productionH5url
      : (Configure.appMode == AppMode.dev ? StaticConfig.devH5url : "");
}

// 静态配置存储区
class StaticConfig {
  // h5 调试时的本地运行地址
  static const String devH5url = "http://192.168.1.33:8082";
  // h5 产品运行时的地址
  static const String productionH5url = "http://192.168.1.33:8082";

  // 复杂化命名前缀
  static const String preName = "zflutter";

  // 与 flutter-core 通讯时的参数分隔符
  static const String argsSpliter = "|_|";

  // iOS AppStore 更新地址
  static const String updateAppStoreUrl =
      "https://apps.apple.com/us/app/flutter%E7%91%9E%E5%A4%AA/id1582156692";
}
