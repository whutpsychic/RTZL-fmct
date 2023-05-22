import 'package:flutter/material.dart';
import './App.dart';

GlobalKey<AppState> appPageKey = GlobalKey();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const App(),
      initialRoute: "/main",
      routes: {
        // web 主页
        '/main': (context) => App(key: appPageKey),
        // // 服务器地址配置页
        // // 此页面可指定 web 主页的地址指向
        // '/ipconfig': (context) => const Ipconfig(),
      },
    );
  }
}
