import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/logging/app_logger.dart';

final class NetworkManager {
  NetworkManager({InternetConnectionChecker? connectionChecker}) : _connectionChecker = connectionChecker ?? _createConnectionChecker();

  final InternetConnectionChecker _connectionChecker;

  static InternetConnectionChecker _createConnectionChecker() {
    return InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 4),
      addresses: [
        AddressCheckOption(uri: Uri.parse('https://www.google.com/generate_204')),
        AddressCheckOption(uri: Uri.parse('https://picsum.photos/1')),
      ],
    );
  }

  Future<bool> get isConnected async {
    try {
      return await _connectionChecker.hasConnection;
    } on Object catch (error, stackTrace) {
      AppLogger.e('The network status could not be checked.', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Stream<bool> get statusChanges {
    return _connectionChecker.onStatusChange.map((status) => status == InternetConnectionStatus.connected).distinct();
  }
}
