import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for current connectivity status
final connectivityProvider = StateProvider<ConnectivityResult>((ref) {
  return ConnectivityResult.none;
});

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  // Initialize and set up connectivity change stream
  static Future<void> initialize() async {
    // Get initial connectivity status
    final initialStatus = await _connectivity.checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      // Update the provider whenever connectivity changes
      container.read(connectivityProvider.notifier).state = result;
    });

    // Set initial state in the provider
    container.read(connectivityProvider.notifier).state = initialStatus;
  }

  // Helper method to check if device is connected to internet
  static bool isConnected(ConnectivityResult status) {
    return status != ConnectivityResult.none;
  }
}

// ProviderContainer available globally for initialization
final container = ProviderContainer();
