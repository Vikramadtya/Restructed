import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

/// Entrypoint for the high-performance local proxy daemon.
/// Runs entirely in the background as root.
Future<void> runProxyDaemon() async {
  try {
    // Gracefully handle termination signals to ensure cleanup
    ProcessSignal.sigint.watch().listen((_) => exit(0));
    ProcessSignal.sigterm.watch().listen((_) => exit(0));

    final interceptor = TrafficInterceptor();
    await interceptor.initialize();
    await interceptor.start();

    // Generate Secure Security Token
    final random = Random.secure();
    final token = List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    stdout.writeln('[TOKEN] $token');

    final enforcer = DaemonEnforcer(interceptor, token);
    await enforcer.start();

    await ProcessSignal.sigterm.watch().first;
  } catch (e, stackTrace) {
    stderr.writeln('FATAL ERROR in runProxyDaemon: $e\n$stackTrace');
    exit(1);
  }
}

/// Coordinates the enforcement of block rules locally on the device via the Daemon.
/// Receives rules via a persistent TCP socket connected to the frontend application, 
/// and translates these rules into immediate system-level effects like modifying 
/// `/etc/hosts` and terminating restricted processes.
class DaemonEnforcer {
  final TrafficInterceptor interceptor;
  final String token;
  
  Set<String> lastDomains = {};
  Set<String> lastApps = {};
  
  Timer? appEnforcementTimer;

  DaemonEnforcer(this.interceptor, this.token);

  Future<void> start() async {
    try {
      final serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 8193);
      stdout.writeln('[DaemonEnforcer] TCP Sync Listener started on port 8193.');

      bool hasConnected = false;
      Timer(const Duration(seconds: 15), () {
        if (!hasConnected) {
          stdout.writeln('[DaemonEnforcer] No client connected within 15s. Shutting down to prevent dangling processes.');
          exit(0);
        }
      });

      serverSocket.listen((Socket client) {
        hasConnected = true;
        client.listen(
          (List<int> data) async {
            try {
              final messages = utf8.decode(data).trim().split('\n');
              for (var message in messages) {
                if (message.isEmpty) continue;
                final payload = jsonDecode(message);
                
                if (payload['token'] != token) {
                  stdout.writeln('[DaemonEnforcer] Unauthorized request. Invalid token.');
                  client.write('${jsonEncode({'event': 'ERROR', 'message': 'Unauthorized'})}\n');
                  client.destroy();
                  return;
                }

                stdout.writeln("[DaemonEnforcer] Received command: ${payload['action']}");

                if (payload['action'] == 'SET_BLOCKLIST') {
                  final domains = List<String>.from(payload['domains'] as List);
                  final apps = List<String>.from(payload['apps'] as List);
                  await applyBlocksDirectly(domains, apps);
                  client.write('${jsonEncode({'event': 'BLOCKLIST_SET'})}\n');
                } else {
                  client.write('${jsonEncode({'event': 'ERROR', 'message': 'Unknown action'})}\n');
                }
              }
            } catch (e) {
              stdout.writeln('[DaemonEnforcer] TCP parse error: $e');
              client.write('${jsonEncode({'event': 'ERROR', 'message': e.toString()})}\n');
            }
          },
          onError: (dynamic error) {
            stdout.writeln('[DaemonEnforcer] TCP client error: $error');
            client.destroy();
            exit(1);
          },
          onDone: () {
            stdout.writeln('[DaemonEnforcer] TCP client disconnected. Waiting 10 seconds for reconnect before exiting...');
            client.destroy();
            hasConnected = false;
            Timer(const Duration(seconds: 10), () {
              if (!hasConnected) {
                stdout.writeln('[DaemonEnforcer] No reconnect within 10s. Exiting daemon to prevent dangling processes.');
                exit(0);
              }
            });
          },
        );
      });
    } catch (e, stackTrace) {
      stderr.writeln('[DaemonEnforcer] Failed to bind TCP Sync Listener: $e\n$stackTrace');
      exit(1);
    }
  }

  Future<void> applyBlocksDirectly(List<String> domains, List<String> apps) async {
    final bool domainsChanged = setEquals(lastDomains, domains.toSet()) == false;
    final bool appsChanged = setEquals(lastApps, apps.toSet()) == false;

    if (!domainsChanged && !appsChanged) {
      stdout.writeln('[DaemonEnforcer] No changes detected. Skipping enforcement.');
      return;
    }

    lastDomains = domains.toSet();
    lastApps = apps.toSet();

    if (domainsChanged) {
      stdout.writeln('[DaemonEnforcer] Applying domain blocks: $lastDomains');
      interceptor.updateActiveDomains(lastDomains);
      await applyToHosts(lastDomains);
    }

    if (appsChanged) {
      stdout.writeln('[DaemonEnforcer] App blocking updated. Monitored apps: $lastApps');
      if (lastApps.isNotEmpty) {
        startAppEnforcementTimer();
      } else {
        stopAppEnforcementTimer();
      }
    }
  }

  void startAppEnforcementTimer() {
    appEnforcementTimer?.cancel();
    // Run immediately and then every 5 seconds
    terminateBlockedApplications(lastApps);
    appEnforcementTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      terminateBlockedApplications(lastApps);
    });
  }

  void stopAppEnforcementTimer() {
    appEnforcementTimer?.cancel();
    appEnforcementTimer = null;
  }

  bool setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> applyToHosts(Set<String> domains) async {
    try {
      final robustDomains = <String>{};
      for (var d in domains) {
        d = d.trim();
        if (d.isEmpty) continue;
        robustDomains.add(d);
        if (!d.startsWith('www.')) {
          robustDomains.add('www.$d');
        }
      }
      


      final blockLines = robustDomains
          .expand((d) => ['127.0.0.2 $d', '::2 $d'])
          .join('\n');
      
      final blockContent = 
          '# --- RESTRUCTED BLOCK START ---\n$blockLines\n# --- RESTRUCTED BLOCK END ---\n';

      final hostsPath = Platform.environment['TEST_MODE'] == 'true' ? 'test_hosts' : '/etc/hosts';

      await Process.run('sed', [
        '-i',
        "''",
        '/^# --- RESTRUCTED BLOCK START ---\$/,/^# --- RESTRUCTED BLOCK END ---\$/d',
        hostsPath
      ]);

      if (robustDomains.isNotEmpty) {
        final hostsFile = File(hostsPath);
        await hostsFile.writeAsString('\n$blockContent', mode: FileMode.append);
      }

      if (Platform.environment['TEST_MODE'] != 'true') {
        await Process.run('ifconfig', ['lo0', 'alias', '127.0.0.2', 'up']);
        await Process.run('ifconfig', ['lo0', 'inet6', 'alias', '::2', 'up']);
        await Process.run('dscacheutil', ['-flushcache']);
        await Process.run('killall', ['-HUP', 'mDNSResponder']);
      }
      
      stdout.writeln('[HostsEnforcer] Successfully updated /etc/hosts and flushed DNS.');
    } catch (e, stackTrace) {
      stderr.writeln('[HostsEnforcer] Failed to apply hosts: $e\n$stackTrace');
    }
  }

  Future<void> terminateBlockedApplications(Set<String> apps) async {
    try {
      for (var app in apps) {
        app = app.trim();
        if (app.isNotEmpty) {
          final result = await Process.run('pkill', ['-x', '-i', '--', app]);
          if (result.exitCode == 0) {
            stdout.writeln('[AppEnforcer] Terminated blocked application: $app');
          }
        }
      }
    } catch (e, stackTrace) {
      stderr.writeln('[AppEnforcer] ERROR terminating applications: $e\n$stackTrace');
    }
  }
}

/// Provides UDP packet interception acting as a local transparent proxy.
/// Intercepts DNS and HTTP/HTTPS packets to capture analytics data and prevent
/// bypassing of local network restrictions by filtering specific IP traffic at the OS level.
class TrafficInterceptor {
  late final RawDatagramSocket udpClient;
  final InternetAddress mainAppAddress = InternetAddress('127.0.0.1');
  static const int mainAppUdpPort = 8192;
  
  Set<String> activeDomains = {};

  void updateActiveDomains(Set<String> domains) {
    activeDomains = domains;
  }

  Future<void> initialize() async {
    try {
      udpClient = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      stdout.writeln('[TrafficInterceptor] UDP Client initialized.');
    } catch (e, stackTrace) {
      stderr.writeln('[TrafficInterceptor] ERROR initializing UDP: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> start() async {
    final isTest = Platform.environment['TEST_MODE'] == 'true';
    final port80 = isTest ? 8080 : 80;
    final port443 = isTest ? 8443 : 443;

    await Future.wait([
      bindAndListen('127.0.0.2', port80),
      bindAndListen('127.0.0.2', port443),
      bindAndListen('::2', port80),
      bindAndListen('::2', port443),
    ]);
    stdout.writeln('[TrafficInterceptor] TCP listeners started.');
  }

  Future<void> bindAndListen(String bindIp, int bindPort) async {
    try {
      final server = await ServerSocket.bind(bindIp, bindPort);
      server.listen(
        handleClientConnection,
        onError: (dynamic e) => stderr.writeln('[TrafficInterceptor] Server error $bindIp:$bindPort: $e'),
      );
    } catch (e, stackTrace) {
      stderr.writeln('[TrafficInterceptor] Unexpected error $bindIp:$bindPort: $e\n$stackTrace');
    }
  }

  void handleClientConnection(Socket client) {
    client.listen(
      (List<int> data) => processTcpPayload(client, data),
      onError: (dynamic e) => safelyDestroyClient(client),
      onDone: () => safelyDestroyClient(client),
      cancelOnError: true,
    );
  }

  void processTcpPayload(Socket client, List<int> rawPacketBytes) {
    try {
      if (activeDomains.isEmpty) {
        safelyDestroyClient(client);
        return;
      }

      final String payloadString = utf8.decode(rawPacketBytes, allowMalformed: true);

      for (final domain in activeDomains) {
        final baseDomain = domain.startsWith('www.') ? domain.substring(4) : domain;
        if (payloadString.contains(baseDomain)) {
          sendAnalyticsHit(domain);
          break;
        }
      }
    } catch (e, stackTrace) {
      stderr.writeln('[TrafficInterceptor] ERROR processing TCP: $e\n$stackTrace');
    } finally {
      safelyDestroyClient(client);
    }
  }

  void sendAnalyticsHit(String domain) {
    try {
      final payload = utf8.encode('HIT:$domain');
      udpClient.send(payload, mainAppAddress, mainAppUdpPort);
    } catch (e, stackTrace) {
      stderr.writeln('[TrafficInterceptor] Failed to send UDP hit: $e\n$stackTrace');
    }
  }

  void safelyDestroyClient(Socket client) {
    try {
      client.destroy();
    } catch (_) {}
  }
}
