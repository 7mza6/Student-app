import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  static final Connectivity _conn = Connectivity();

  static Future<bool> get isOnline async {
    final result = await _conn.checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn;
  }
}
