import 'package:logger/logger.dart';
import 'package:restructed/backend/daemon_client/daemon_connection.dart';
import 'package:restructed/backend/categories/category_repository.dart';
import 'package:restructed/backend/rules/rule_repository.dart';
import 'dart:io';
import 'dart:convert';
import 'package:restructed/backend/analytics/analytics_repository.dart';
import 'package:restructed/backend/settings/settings_service.dart';

/// Acts as the high-level API wrapper for the frontend application to interact with the Daemon.
/// It listens to incoming UDP analytics hits (interceptions), handles TCP syncing of block rules
/// to the Daemon Enforcer, and integrates with the Drift database repositories to record analytics.
class DaemonService {
  final Map<String, DateTime> lastHits = {};
  final DaemonConnectionManager connectionManager;
  final RuleRepository ruleRepository;
  final CategoryRepository categoryRepository;
  final AnalyticsRepository analyticsRepository;
  final SettingsService settingsService;
  final Logger logger;
  final void Function() onSyncComplete;
  final void Function() onAnalyticsUpdate;

  DaemonService(
    this.connectionManager,
    this.ruleRepository,
    this.categoryRepository,
    this.analyticsRepository,
    this.settingsService,
    this.logger,
    this.onSyncComplete,
    this.onAnalyticsUpdate,
  ) {
    initListener();
    initUdpListener();
  }

  void initListener() {
    connectionManager.events.listen((payload) async {
      try {
        final event = payload['event'];
        logger.i('DaemonService received event: $event');

        switch (event) {
          case 'BLOCKLIST_SET':
            logger.i('Daemon reported blocklist set. Marking all rules as synced.');
            final rules = await ruleRepository.getAllRules();
            for (var rule in rules) {
              if (rule.syncStatus == 'staged') {
                await ruleRepository.updateRule(rule.copyWith(syncStatus: 'synced'));
              }
            }
            final categories = await categoryRepository.getAllCategories();
            for (var category in categories) {
              if (category.syncStatus == 'staged') {
                await categoryRepository.updateCategory(category.copyWith(syncStatus: 'synced'));
              }
            }
            onSyncComplete();
            break;
          case 'ERROR':
            logger.e("Daemon reported error: \${payload['message']}");
            break;
          default:
            logger.w('Unknown event from Daemon: $event');
        }
      } catch (e) {
        logger.e('Failed to process Daemon event: $e');
      }
    });
  }

  Future<void> initUdpListener() async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 8192);
      logger.i('DaemonService UDP Listener started on port 8192');
      socket.listen((RawSocketEvent event) async {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final payload = utf8.decode(datagram.data);
            if (payload.startsWith('HIT:')) {
              final domain = payload.substring(4);
              final now = DateTime.now();
              final lastHit = lastHits[domain];
              final debounceSeconds = settingsService.analyticsDebounceSeconds;

              if (lastHit == null || now.difference(lastHit).inSeconds >= debounceSeconds) {
                lastHits[domain] = now;
                logger.i('Received HIT for domain: $domain (Logged)');
                await analyticsRepository.logAttempt(domain);
                onAnalyticsUpdate();
              } else {
                logger.d('Ignored HIT for domain: $domain (Debounced)');
              }
            }
          }
        }
      });
    } catch (e) {
      logger.e('Failed to bind UDP listener: $e');
    }
  }
}
