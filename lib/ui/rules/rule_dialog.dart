import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restructed/backend/rules/block_rule.dart';
import 'package:restructed/ui/core/app_providers.dart';

import 'package:restructed/ui/rules/components/rule_basic_info.dart';
import 'package:restructed/ui/rules/components/rule_enforcement_logic.dart';
import 'package:restructed/ui/rules/components/rule_advanced_options.dart';

enum RuleMode { duration, schedule }

void showRuleDialog(
  BuildContext context,
  WidgetRef ref, {
  BlockRule? existingRule,
  String? initialCategoryId,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    pageBuilder: (context, animation, secondaryAnimation) {
      return RuleDialogWrapper(
        existingRule: existingRule,
        initialCategoryId: initialCategoryId,
      );
    },
  );
}

class RuleDialogWrapper extends ConsumerStatefulWidget {
  final BlockRule? existingRule;
  final String? initialCategoryId;

  const RuleDialogWrapper({
    super.key,
    this.existingRule,
    this.initialCategoryId,
  });

  @override
  ConsumerState<RuleDialogWrapper> createState() => RuleDialogWrapperState();
}

class RuleDialogWrapperState extends ConsumerState<RuleDialogWrapper> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController domainController;
  late TextEditingController durationController;
  late FocusNode domainFocusNode;

  late bool isAppRule;
  late bool isStrictMode;

  RuleMode ruleMode = RuleMode.duration;
  bool isIndefinite = false;

  late List<int> scheduledDays;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String durationUnit = 'Hours';
  String? categoryId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    domainController = TextEditingController(
      text: widget.existingRule?.domain ?? '',
    );
    domainFocusNode = FocusNode();
    durationController = TextEditingController();

    domainFocusNode.addListener(() {
      if (!domainFocusNode.hasFocus && !isAppRule) {
        formatDomain();
      }
    });

    isAppRule = widget.existingRule?.isAppRule ?? false;
    isStrictMode = widget.existingRule?.isStrictMode ?? false;
    scheduledDays = widget.existingRule?.scheduledDays != null
        ? List.from(widget.existingRule!.scheduledDays!)
        : [];

    if (widget.existingRule?.startTime != null) {
      final parts = widget.existingRule!.startTime!.split(':');
      startTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }

    if (widget.existingRule?.endTime != null) {
      final parts = widget.existingRule!.endTime!.split(':');
      endTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 17,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }

    if (scheduledDays.isNotEmpty || startTime != null) {
      ruleMode = RuleMode.schedule;
    }

    if (widget.existingRule != null) {
      final int minutes = widget.existingRule!.blockDuration.inMinutes;
      if (minutes >= 36500 * 24 * 60) {
        isIndefinite = true;
        durationController.text = '1';
      } else if (minutes % (30 * 24 * 60) == 0 && minutes > 0) {
        durationUnit = 'Months';
        durationController.text = (minutes / (30 * 24 * 60)).toStringAsFixed(
          0,
        );
      } else if (minutes % (7 * 24 * 60) == 0 && minutes > 0) {
        durationUnit = 'Weeks';
        durationController.text = (minutes / (7 * 24 * 60)).toStringAsFixed(0);
      } else if (minutes % (24 * 60) == 0 && minutes > 0) {
        durationUnit = 'Days';
        durationController.text = (minutes / (24 * 60)).toStringAsFixed(0);
      } else {
        durationUnit = 'Hours';
        durationController.text = (minutes / 60.0)
            .toStringAsFixed(1)
            .replaceAll(RegExp(r'\.0$'), '');
      }
    } else {
      durationController.text = '1';
    }

    categoryId = widget.existingRule?.categoryId ?? widget.initialCategoryId;
  }

  @override
  void dispose() {
    domainFocusNode.dispose();
    domainController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void formatDomain() {
    String domain = domainController.text.trim();
    if (domain.isNotEmpty) {
      domain = domain.toLowerCase();
      domain = domain.replaceAll(RegExp(r'^https?://'), '');
      domain = domain.replaceAll(RegExp(r'^www\.'), '');
      domain = domain.replaceAll(RegExp(r'/.*$'), '');
      if (domainController.text != domain) {
        domainController.text = domain;
      }
    }
  }

  Future<void> saveRule() async {
    if (!isAppRule) formatDomain();

    if (!formKey.currentState!.validate()) return;
    if (ruleMode == RuleMode.schedule && scheduledDays.isEmpty) {
      showError('Please select at least one active day for the schedule.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final domain = domainController.text.trim();

      // Prevent Duplicate Domains
      final rules = await ref.read(ruleRepositoryProvider).getAllRules();
      if (widget.existingRule == null && rules.any((r) => r.domain == domain)) {
        showError('A rule for "$domain" already exists!');
        setState(() => isLoading = false);
        return;
      }

      String? formattedStart;
      String? formattedEnd;
      if (ruleMode == RuleMode.schedule &&
          startTime != null &&
          endTime != null) {
        formattedStart =
            '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
        formattedEnd =
            '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
      }

      final rule = BlockRule(
        id:
            widget.existingRule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: categoryId!,
        domain: domain,
        blockDuration: () {
          if (ruleMode == RuleMode.schedule || isIndefinite) {
            return const Duration(days: 36500);
          }
          final double val =
              double.tryParse(durationController.text.trim()) ?? 1.0;
          if (durationUnit == 'Months') {
            return Duration(minutes: (val * 30 * 24 * 60).toInt());
          }
          if (durationUnit == 'Weeks') {
            return Duration(minutes: (val * 7 * 24 * 60).toInt());
          }
          if (durationUnit == 'Days') {
            return Duration(minutes: (val * 24 * 60).toInt());
          }
          return Duration(minutes: (val * 60).toInt());
        }(),
        isActive: widget.existingRule?.isActive ?? true,
        isStrictMode: isStrictMode,
        isAppRule: isAppRule,
        scheduledDays: ruleMode == RuleMode.schedule ? scheduledDays : null,
        startTime: formattedStart,
        endTime: formattedEnd,
      );

      final daemonApi = ref.read(daemonApiProvider);
      final ruleRepo = ref.read(ruleRepositoryProvider);

      try {
        final stagedRule = rule.copyWith(syncStatus: 'staged');
        
        if (widget.existingRule == null) {
          await ruleRepo.createRule(stagedRule);
        } else {
          await ruleRepo.updateRule(stagedRule);
        }
        await daemonApi.triggerSync();
        
        ref.invalidate(rulesProvider);
        ref.invalidate(rulesByCategoryProvider);
      } catch (e) {
        showError('Failed to communicate with Daemon: $e');
        setState(() => isLoading = false);
        return;
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      showError("An unexpected error occurred: ${e.toString().replaceAll('Exception: ', '')}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.existingRule == null
                            ? 'Add New Rule'
                            : 'Edit Rule',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Form(
                    key: formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        RuleBasicInfo(
                          categoryId: categoryId,
                          onCategoryChanged: (val) =>
                              setState(() => categoryId = val),
                          isAppRule: isAppRule,
                          onAppRuleChanged: (val) =>
                              setState(() => isAppRule = val),
                          domainController: domainController,
                          domainFocusNode: domainFocusNode,
                          onFormatDomain: formatDomain,
                        ),
                        const SizedBox(height: 32),
                        RuleEnforcementLogic(
                          ruleMode: ruleMode,
                          onRuleModeChanged: (val) =>
                              setState(() => ruleMode = val),
                          isIndefinite: isIndefinite,
                          onIndefiniteChanged: (val) =>
                              setState(() => isIndefinite = val),
                          durationController: durationController,
                          durationUnit: durationUnit,
                          onDurationUnitChanged: (val) =>
                              setState(() => durationUnit = val),
                          scheduledDays: scheduledDays,
                          onDayToggled: (i) => setState(() {
                            if (scheduledDays.contains(i)) {
                              scheduledDays.remove(i);
                            } else {
                              scheduledDays.add(i);
                            }
                          }),
                          startTime: startTime,
                          onStartTimeChanged: (val) =>
                              setState(() => startTime = val),
                          endTime: endTime,
                          onEndTimeChanged: (val) =>
                              setState(() => endTime = val),
                        ),
                        const SizedBox(height: 32),
                        RuleAdvancedOptions(
                          isStrictMode: isStrictMode,
                          onStrictModeChanged: (val) =>
                              setState(() => isStrictMode = val),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: isLoading ? null : saveRule,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: const Color(0xFF6366F1),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.existingRule == null
                                    ? 'Create Rule'
                                    : 'Update Rule',
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
