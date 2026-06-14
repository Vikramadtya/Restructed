import 'dart:io';
import 'package:flutter/material.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Application',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for an app...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterApps,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredApps.isEmpty
                  ? const Center(child: Text('No applications found.'))
                  : ListView.builder(
                      itemCount: filteredApps.length,
                      itemBuilder: (context, index) {
                        final appName = filteredApps[index];
                        return ListTile(
                          leading: const Icon(Icons.desktop_mac),
                          title: Text(appName),
                          trailing: const Icon(Icons.chevron_right, size: 16),
                          onTap: () {
                            Navigator.of(context).pop(appName);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
