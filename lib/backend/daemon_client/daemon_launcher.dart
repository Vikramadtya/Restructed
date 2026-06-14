import 'dart:io';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DaemonLauncher {
  final Logger logger;
  String? token;
  bool userCancelled = false;
  
  DaemonLauncher(this.logger);

  bool get hasUserCancelled => userCancelled;

  void resetCancellation() {
    userCancelled = false;
  }

  Future<void> launchDaemon() async {
    if (token != null) return; // Already running and we have the token
    if (userCancelled) {
      logger.w('Skipping daemon launch because user previously cancelled authentication.');
      throw Exception('User cancelled authentication.');
    }

    logger.i('Launching Daemon via osascript...');
    final currentDir = Directory.current.path;
    
    try {
      final supportDir = await getApplicationSupportDirectory();
      final daemonDir = Directory(p.join(supportDir.path, 'daemon_logs'));
      if (!await daemonDir.exists()) {
        await daemonDir.create(recursive: true);
      }
      
      final logFilePath = p.join(daemonDir.path, 'daemon_${DateTime.now().millisecondsSinceEpoch}.log');
      final logFile = File(logFilePath);
      
      // Create file and secure it before root writes to it
      await logFile.create();
      await Process.run('chmod', ['600', logFilePath]);

      // 2. Create a launch script to avoid AppleScript escaping hell
      final scriptFile = File(p.join(daemonDir.path, 'launch_restructed.sh'));
      final resolvedExec = Platform.resolvedExecutable;
      
      final isDart = resolvedExec.endsWith('dart') || resolvedExec.endsWith('dart.exe');
      final execArgs = isDart ? '"$resolvedExec" run lib/main.dart' : '"$resolvedExec"';
      
      await scriptFile.writeAsString('''#!/bin/bash
cd "\$1"
$execArgs --proxy-daemon > "\$2" 2>&1 < /dev/null &
echo \$!
''');
      await Process.run('chmod', ['+x', scriptFile.path]);

      // 3. Run the script with administrator privileges via osascript
      // Passes currentDir as \$1, logFilePath as \$2
      // In AppleScript, we quote the arguments to avoid injection
      String escapeArg(String arg) => arg.replaceAll('\\\\', '\\\\\\\\').replaceAll('"', '\\\\\\"');
      
      final appleScript = 'do shell script "\\"${escapeArg(scriptFile.path)}\\" \\"${escapeArg(currentDir)}\\" \\"${escapeArg(logFilePath)}\\"" with administrator privileges';
      
      final result = await Process.run('osascript', ['-e', appleScript]);
      
      if (result.exitCode != 0) {
        logger.e('osascript failed: ${result.stderr}');
        final stderrStr = result.stderr.toString().toLowerCase();
        if (stderrStr.contains('cancel') || stderrStr.contains('-128') || stderrStr.contains('authentication')) {
          userCancelled = true;
          throw Exception('User cancelled or authentication failed.');
        }
        throw Exception('osascript failed: ${result.stderr}');
      }

      final pid = result.stdout.toString().trim();
      logger.i('Daemon started in background with PID: $pid');

      // 4. Poll the log file for the token
      logger.i('Waiting for daemon to write token to log...');
      final completer = Completer<void>();
      
      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        if (!logFile.existsSync()) return;
        
        final lines = await logFile.readAsLines();
        for (var line in lines) {
          if (line.contains('[TOKEN]')) {
            token = line.split('[TOKEN]')[1].trim();
            logger.i('Daemon launched successfully. Token acquired: $token');
            timer.cancel();
            if (!completer.isCompleted) completer.complete();
            return;
          }
        }
      });

      // Timeout after 15 seconds
      await Future.any([
        completer.future,
        Future<void>.delayed(const Duration(seconds: 15)).then((_) {
          if (!completer.isCompleted) throw Exception('Timeout waiting for daemon token in log file');
        }),
      ]);

    } catch (e) {
      logger.e('Failed to launch daemon: $e');
      throw Exception('Daemon launch failed: $e');
    }
  }

  void stopDaemon() {
    // We would need to kill the saved PID, but for now we just clear the token
    token = null;
  }
}
