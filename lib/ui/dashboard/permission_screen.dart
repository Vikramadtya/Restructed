import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restructed/ui/core/app_providers.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => PermissionScreenState();
}

class PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool isAuthenticating = false;
  String? error;

  Future<void> authenticate() async {
    setState(() {
      isAuthenticating = true;
      error = null;
    });

    try {
      final launcher = ref.read(daemonLauncherProvider);
      launcher.resetCancellation();
      await launcher.launchDaemon();
      
      // Once launched, connect the manager and trigger a sync.
      final manager = ref.read(daemonConnectionManagerProvider);
      await manager.connect();
      
      final daemonApi = ref.read(daemonApiProvider);
      await daemonApi.triggerSync();
      
      ref.read(authStatusProvider.notifier).checkAuth();
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security_outlined,
                size: 64,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                'System Privileges Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Restructed needs system privileges to securely enforce website blocks and intercept local traffic. '
                'You will be prompted to enter your macOS password.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: isAuthenticating ? null : authenticate,
                  icon: isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock_open),
                  label: Text(isAuthenticating ? 'Authenticating...' : 'Authenticate'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
