import 'package:app_v2ray_manager/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settingsProvider, themeProvider, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Bypass LAN'),
                value: settingsProvider.bypassLAN,
                onChanged: (value) => settingsProvider.setBypassLAN(value),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
              ListTile(
                title: const Text('Blocked Apps'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showBlockedAppsDialog(context, settingsProvider),
              ),
              ListTile(
                title: const Text('Bypass Subnets'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showBypassSubnetsDialog(context, settingsProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBlockedAppsDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Apps'),
        content: SingleChildScrollView(
          child: Column(
            children: provider.blockedApps.map((app) => ListTile(
              title: Text(app),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  final newList = List<String>.from(provider.blockedApps)..remove(app);
                  provider.setBlockedApps(newList);
                },
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Add App'),
            onPressed: () {
              // TODO: Implement app selection
            },
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showBypassSubnetsDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bypass Subnets'),
        content: SingleChildScrollView(
          child: Column(
            children: provider.bypassSubnets.map((subnet) => ListTile(
              title: Text(subnet),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  final newList = List<String>.from(provider.bypassSubnets)..remove(subnet);
                  provider.setBypassSubnets(newList);
                },
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Add Subnet'),
            onPressed: () {
              // TODO: Implement subnet input
            },
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}