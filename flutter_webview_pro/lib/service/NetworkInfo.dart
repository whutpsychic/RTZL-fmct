// ignore_for_file: file_names, depend_on_referenced_packages
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static Future<bool> check() async {
    return await ConnectivityWrapper.instance.isConnected;
  }

  static Future<String> checkType() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult.toString();
  }
}
