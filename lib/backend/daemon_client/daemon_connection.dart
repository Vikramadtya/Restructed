import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:restructed/backend/daemon_client/daemon_launcher.dart';

/// Manages the persistent TCP connection between the frontend UI and the background Proxy Daemon.
/// Handles connection lifecycle, token authentication, payload delivery, and event broadcasting.
class DaemonConnectionManager {
  final Logger logger;
  final DaemonLauncher launcher;
  final void Function() onAuthLost;
  Socket? socket;
  final eventController = StreamController<Map<String, dynamic>>.broadcast();
  bool isConnecting = false;
  Timer? reconnectTimer;

  DaemonConnectionManager(this.logger, this.launcher, this.onAuthLost);

  Stream<Map<String, dynamic>> get events => eventController.stream;

  Future<void> connect() async {
    if (socket != null || isConnecting) return;
    isConnecting = true;

    try {
      logger.i('Attempting to connect to Daemon on 127.0.0.1:8193...');
      socket = await Socket.connect(InternetAddress.loopbackIPv4, 8193, timeout: const Duration(seconds: 2));
      isConnecting = false;
      failedAttempts = 0;
      logger.i('Connected to Daemon successfully.');

      socket!.listen(
        (List<int> data) {
          try {
            final messages = utf8.decode(data).trim().split('\n');
            for (var msg in messages) {
              if (msg.isNotEmpty) {
                final payload = jsonDecode(msg) as Map<String, dynamic>;
                eventController.add(payload);
              }
            }
          } catch (e) {
            logger.e('Failed to decode Daemon message: $e');
          }
        },
        onError: (dynamic e) {
          logger.e('Daemon TCP socket error: $e');
          handleDisconnect();
        },
        onDone: () {
          logger.w('Daemon TCP socket closed by server.');
          handleDisconnect();
        },
      );
    } catch (e) {
      isConnecting = false;
      logger.e('Failed to connect to Daemon: $e');
      handleDisconnect();
    }
  }

  int failedAttempts = 0;

  void handleDisconnect() {
    socket?.destroy();
    socket = null;
    isConnecting = false;
    
    if (launcher.hasUserCancelled) {
      logger.w('Not scheduling reconnect because user cancelled authentication.');
      return;
    }

    failedAttempts++;
    if (failedAttempts >= 3) {
      logger.w('Daemon unreachable after 3 attempts. Clearing token to require re-authentication.');
      launcher.stopDaemon();
      onAuthLost();
      return;
    }

    // Attempt to reconnect after 3 seconds
    reconnectTimer?.cancel();
    reconnectTimer = Timer(const Duration(seconds: 3), () {
      connect();
    });
  }

  void sendCommand(Map<String, dynamic> command) {
    if (socket == null) {
      logger.w("Not connected to daemon. Dropping command: ${command['action']}");
      return;
    }
    try {
      final payload = Map<String, dynamic>.from(command);
      if (launcher.token != null) {
        payload['token'] = launcher.token;
      }
      socket!.write('${jsonEncode(payload)}\n');
    } catch (e) {
      logger.e('Failed to send command to Daemon: $e');
      handleDisconnect();
      throw Exception('Failed to communicate with Daemon');
    }
  }

  void dispose() {
    reconnectTimer?.cancel();
    socket?.destroy();
    eventController.close();
  }
}
