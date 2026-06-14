import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'package:restructed/backend/core/injection.dart';
import 'package:restructed/daemon/proxy_daemon.dart';
import 'package:restructed/ui/core/app_theme.dart';
import 'package:restructed/ui/dashboard/dashboard_screen.dart';
import 'package:restructed/ui/core/app_providers.dart';

// Initialize Talker globally
final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    maxHistoryItems: 500,
    useConsoleLogs: true,
  ),
);

void main(List<String> args) async {
  if (args.contains('--proxy-daemon')) {
    await runProxyDaemon();
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();

  // Setup Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://example@sentry.io/1234567'; // Replace with real DSN
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      ProviderScope(
        observers: [
          TalkerRiverpodObserver(talker: talker),
        ],
        child: const RestructedApp(),
      ),
    ),
  );
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

    return MacosApp(
      title: 'Restructed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}
