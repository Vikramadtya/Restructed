import 'package:restructed/backend/daemon_client/daemon_connection.dart';
import 'package:restructed/backend/rules/block_rule.dart';
import 'package:restructed/backend/categories/category.dart';
import 'package:restructed/backend/rules/rule_repository.dart';
import 'package:restructed/backend/categories/category_repository.dart';
import 'package:restructed/backend/settings/settings_service.dart';

class DaemonApi {
  final DaemonConnectionManager connectionManager;
  final RuleRepository ruleRepo;
  final CategoryRepository categoryRepo;
  final SettingsService settingsService;

  DaemonApi(this.connectionManager, this.ruleRepo, this.categoryRepo, this.settingsService);

  Future<void> triggerSync() async {
    final rules = await ruleRepo.getAllRules();
    final categories = await categoryRepo.getAllCategories();
    syncAll(rules, categories);
  }

  void syncAll(List<BlockRule> rules, List<Category> categories) {
    final activeCategoryIds = categories.where((c) => c.isActive).map((c) => c.id).toSet();
    
    final activeDomains = <String>{};
    final activeApps = <String>{};
    
    for (final rule in rules) {
      if (rule.isActive && activeCategoryIds.contains(rule.categoryId)) {
        if (rule.isAppRule) {
          activeApps.add(rule.domain);
        } else {
          activeDomains.add(rule.domain);
        }
      }
    }

    if (settingsService.disablePrivateRelay && activeDomains.isNotEmpty) {
      activeDomains.add('mask.icloud.com');
      activeDomains.add('mask-h2.icloud.com');
    }

    connectionManager.sendCommand({
      'action': 'SET_BLOCKLIST',
      'domains': activeDomains.toList(),
      'apps': activeApps.toList(),
    });
  }
}
