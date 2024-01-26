// ignore_for_file: file_names
// ------------------------- 欢迎页 -------------------------
import 'package:flutter/material.dart';
import '../main.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Material(
      child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '欢迎使用',
                style: TextStyle(
                  color: Color.fromRGBO(50, 50, 50, 1),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              // 分隔元素
              Container(height: h / 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MyApp(key: appPageKey)));
                },
                child: const Text('开始使用'),
              ),
            ],
          )),
    );
  }
}
