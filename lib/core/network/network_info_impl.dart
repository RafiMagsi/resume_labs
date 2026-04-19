import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();

    if (result is List<ConnectivityResult>) {
      return !result.contains(ConnectivityResult.none);
    }

    return result != ConnectivityResult.none;
  }
}