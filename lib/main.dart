import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restructed/backend/core/injection.dart';
import 'package:restructed/daemon/proxy_daemon.dart';
import 'package:restructed/ui/core/app_theme.dart';
import 'package:restructed/ui/dashboard/dashboard_screen.dart';
import 'package:restructed/ui/core/app_providers.dart';

void main(List<String> args) async {
  if (args.contains('--proxy-daemon')) {
    await runProxyDaemon();
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();

  runApp(const ProviderScope(child: RestructedApp()));
}

class RestructedApp extends ConsumerStatefulWidget {
  const RestructedApp({super.key});

  @override
  ConsumerState<RestructedApp> createState() => RestructedAppState();
}

class RestructedAppState extends ConsumerState<RestructedApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Restructed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
