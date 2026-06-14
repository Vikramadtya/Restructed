import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
    return AlertDialog(
      icon: const Icon(LucideIcons.monitor, size: 56),
      title: const Text('Select Application'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for an app...',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterApps,
            ),
            const Gap(16),
            SizedBox(
              height: 300,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredApps.isEmpty
                  ? const Center(child: Text('No applications found.'))
                  : ListView.builder(
                      itemCount: filteredApps.length,
                      itemBuilder: (context, index) {
                        final appName = filteredApps[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(appName);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.monitor, size: 20, color: Colors.grey),
                                const Gap(16),
                                Expanded(child: Text(appName, style: const TextStyle(fontSize: 16))),
                                const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
