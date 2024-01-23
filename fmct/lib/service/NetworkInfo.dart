// ignore_for_file: file_names, depend_on_referenced_packages
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static Future<String> checkType() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult.toString();
  }
}
