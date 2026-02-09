import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/core/globals.dart';
import 'package:pos/presentation/dashboard/bloc/dashboard_bloc.dart';

/// A wrapper widget that listens to connectivity changes and shows snackbar notifications
/// when the device goes online or offline.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final ConnectivityService connectivityService;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    required this.connectivityService,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late final Stream<bool> _connectionStream;
  bool? _previousConnectionState;

  @override
  void initState() {
    super.initState();
    _connectionStream = widget.connectivityService.connectionChange;
    // Initialize with current state
    _previousConnectionState = widget.connectivityService.hasConnection;
  }

  void _showConnectivitySnackbar(BuildContext context, bool isConnected) {
    // Only show snackbar if state actually changed and it's not the initial state
    if (_previousConnectionState != null) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isConnected ? 'Back online' : 'No internet connection',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

      scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

      // Trigger dashboard refresh when back online
      if (isConnected && !_previousConnectionState!) {
        _onConnectionRestored(context);
      }
    }
    _previousConnectionState = isConnected;
  }

  void _onConnectionRestored(BuildContext context) {
    // Trigger dashboard refresh via BLoC
    try {
      context.read<DashboardBloc>().add(RefreshDashboardData());
    } catch (e) {
      // Dashboard BLoC might not be available in all contexts
      debugPrint('Could not refresh dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectionStream,
      initialData: widget.connectivityService.hasConnection,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final isConnected = snapshot.data!;
          // Show snackbar when connection state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showConnectivitySnackbar(context, isConnected);
            }
          });
        }
        return widget.child;
      },
    );
  }
}
