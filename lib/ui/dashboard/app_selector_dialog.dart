import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';

class AppSelectorDialog extends StatefulWidget {
  const AppSelectorDialog({super.key});

  @override
  State<AppSelectorDialog> createState() => AppSelectorDialogState();
}

class AppSelectorDialogState extends State<AppSelectorDialog> {
  List<String> allApps = [];
  List<String> filteredApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    try {
      final appDir = Directory('/Applications');
      final systemAppDir = Directory('/System/Applications');
      final userAppDir = Directory(
        '${Platform.environment["HOME"]}/Applications',
      );

      final List<String> apps = [];

      for (final dir in [appDir, systemAppDir, userAppDir]) {
        if (await dir.exists()) {
          final entries = dir.listSync();
          for (final entry in entries) {
            if (entry is Directory && entry.path.endsWith('.app')) {
              // Extract just the app name without .app
              final name = entry.path.split('/').last.replaceAll('.app', '');
              if (!apps.contains(name)) apps.add(name);
            }
          }
        }
      }

      apps.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (mounted) {
        setState(() {
          allApps = apps;
          filteredApps = apps;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterApps(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredApps = allApps;
      } else {
        filteredApps = allApps
            .where((app) => app.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosAlertDialog(
      appIcon: const MacosIcon(LucideIcons.monitor, size: 56),
      title: const Text('Select Application'),
      message: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MacosTextField(
            placeholder: 'Search for an app...',
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: MacosIcon(LucideIcons.search, size: 16),
            ),
            onChanged: filterApps,
          ),
          const Gap(16),
          SizedBox(
            height: 300,
            child: isLoading
                ? const Center(child: ProgressCircle())
                : filteredApps.isEmpty
                ? const Center(child: Text('No applications found.'))
                : ListView.builder(
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final appName = filteredApps[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(appName);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: MacosColors.systemGrayColor.withValues(alpha: 0.2))),
                          ),
                          child: Row(
                            children: [
                              const MacosIcon(LucideIcons.monitor, size: 16, color: MacosColors.systemGrayColor),
                              const Gap(12),
                              Expanded(child: Text(appName)),
                              const MacosIcon(LucideIcons.chevronRight, size: 16, color: MacosColors.systemGrayColor),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        secondary: true,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    );
  }
}
