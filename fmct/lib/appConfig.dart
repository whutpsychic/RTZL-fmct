// 控制阀
class Configure {
  // 调试模式
  // 会连接到本地网页进行调试
  static const bool debugging = true;
}

// 最终控制结果
class AppConfig {
  // h5 地址
  static String h5url = Configure.debugging
      ? StaticConfig.debuggingh5url
      : StaticConfig.demoh5url;
}

// 静态配置存储区
class StaticConfig {
  // h5 调试时的本地运行地址
  static const String debuggingh5url = "http://192.168.1.33:8080";
  // h5 demo时的外部运行地址
  static const String demoh5url = "https://whutpsychic.gitee.io/flutter-core";

  // 复杂化命名前缀
  static const String preName = "zflutter";

  // 与 flutter-core 通讯时的参数分隔符
  static const String argsSpliter = "|_|";

  // iOS AppStore 更新地址
  static const String updateAppStoreUrl =
      "https://apps.apple.com/us/app/flutter%E7%91%9E%E5%A4%AA/id1582156692";
}
