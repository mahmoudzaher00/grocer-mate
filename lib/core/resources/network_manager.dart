import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Manages network connectivity and provides real-time updates.
class NetworkManager {
  static StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  /// Checks the initial connectivity status.
  static Future<bool> checkConnection() async {
    return await InternetConnectionChecker.instance.hasConnection;
  }
  /// Listens for changes in network connectivity.
  static void monitorConnection(void Function(bool isConnected) onChange) {
    _connectionSubscription =InternetConnectionChecker.instance
        .onStatusChange
        .listen((InternetConnectionStatus status) {
      onChange(status == InternetConnectionStatus.connected);
    });
  }

  /// Disposes of the connection listener.
  static void dispose() {
    _connectionSubscription?.cancel();
  }
}

/// Singleton class to provide a network connectivity notifier.
class NetworkConnectivityNotifier {
  // Private constructor to enforce singleton pattern.
  NetworkConnectivityNotifier._();

  /// The single instance of the notifier.
  static final NetworkConnectivityNotifier instance = NetworkConnectivityNotifier._();

  /// Notifies listeners about the current network connectivity status.
  ValueNotifier<bool> isConnected = ValueNotifier(true);

  // Subscription to monitor network changes.
  StreamSubscription<InternetConnectionStatus>? _statusSubscription;

  /// Initializes the notifier and starts monitoring connectivity.
  Future<void> initialize() async {
    // Setup listener FIRST
    _statusSubscription = InternetConnectionChecker.instance.onStatusChange.listen((status) {
      isConnected.value = status == InternetConnectionStatus.connected;
    });

    // Then fetch status AFTER listener is active
    final hasConnection = await InternetConnectionChecker.instance.hasConnection;
    isConnected.value = hasConnection;

  }
  /// Disposes of the status listener.
  void dispose() {
    _statusSubscription?.cancel();
  }

}

