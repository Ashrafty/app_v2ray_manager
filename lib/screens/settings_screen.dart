import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/theme_provider.dart';
import 'bypass_subnets_screen.dart';
import 'blocked_apps_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                subtitle: Text(
                  settingsProvider.bypassLAN
                      ? 'Local network traffic bypasses VPN'
                      : 'All traffic goes through VPN tunnel',
                  style: TextStyle(
                    color: settingsProvider.bypassLAN ? Colors.orange : Colors.blue,
                    fontSize: 12,
                  ),
                ),
                value: settingsProvider.bypassLAN,
                onChanged: (value) => _toggleBypassLAN(context, settingsProvider, value),
                secondary: Icon(
                  settingsProvider.bypassLAN ? Icons.home_outlined : Icons.vpn_lock,
                  color: settingsProvider.bypassLAN ? Colors.orange : Colors.blue,
                ),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
              ListTile(
                title: const Text('Blocked Apps'),
                subtitle: Text('${settingsProvider.blockedApps.length} apps blocked'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToBlockedApps(context),
              ),
              ListTile(
                title: const Text('Bypass Subnets'),
                subtitle: Text('${settingsProvider.bypassSubnets.length} subnets configured'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToBypassSubnets(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToBlockedApps(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BlockedAppsScreen(),
      ),
    );
  }

  void _toggleBypassLAN(BuildContext context, SettingsProvider provider, bool value) async {
    await provider.setBypassLAN(value);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'LAN bypass enabled - Local network traffic will bypass VPN'
                : 'LAN bypass disabled - All traffic will go through VPN tunnel',
          ),
          backgroundColor: value ? Colors.orange : Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Learn More',
            textColor: Colors.white,
            onPressed: () => _showBypassLANHelp(context),
          ),
        ),
      );
    }
  }

  void _showBypassLANHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LAN Bypass Explained'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is LAN Bypass?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'LAN (Local Area Network) bypass allows traffic to local network devices to skip the VPN tunnel and use direct routing.',
              ),
              SizedBox(height: 16),
              Text(
                'When Enabled:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                '• Access local printers, file shares, and devices\n'
                '• Connect to router admin panels (192.168.x.x)\n'
                '• Use local development servers\n'
                '• Access NAS and IoT devices\n'
                '• Faster local network performance',
              ),
              SizedBox(height: 16),
              Text(
                'When Disabled:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
              ),
              SizedBox(height: 8),
              Text(
                '• All traffic goes through VPN tunnel\n'
                '• Maximum privacy and security\n'
                '• Local devices may not be accessible\n'
                '• Slower local network access',
              ),
              SizedBox(height: 16),
              Text(
                'Security Note:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 8),
              Text(
                'LAN bypass reduces privacy for local network traffic. Only enable if you need to access local devices and trust your local network.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _navigateToBypassSubnets(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BypassSubnetsScreen(),
      ),
    );
  }
}