// ignore_for_file: file_names, use_build_context_synchronously
import 'package:flutter/material.dart';

class NoNetwork extends StatefulWidget {
  const NoNetwork({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NoNetworkViewState();
}

class _NoNetworkViewState extends State<NoNetwork> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Container(
      width: w,
      height: h,
      color: Colors.white,
      child: Center(child: Image.asset("assets/image/noNetwork.png")),
    );
  }
}
