import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/v2ray_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/v2ray_config_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<V2RayProvider, SettingsProvider>(
      builder: (context, v2rayProvider, settingsProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIndicator(context, v2rayProvider),
              const SizedBox(height: 20),
              if (v2rayProvider.isConnected) ...[
                V2RayConfigCard(config: v2rayProvider.currentConfig!),
                const SizedBox(height: 20),
                _buildBypassStatusCard(context, settingsProvider),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(v2rayProvider.isConnected ? Icons.link_off : Icons.link),
                label: Text(v2rayProvider.isConnected
                    ? AppConstants.buttonDisconnect
                    : AppConstants.buttonConnect),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: v2rayProvider.isConnected
                    ? () => _disconnect(context, v2rayProvider)
                    : () => _showConnectDialog(context, v2rayProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, V2RayProvider provider) {
    final isConnected = provider.isConnected;
    final color = isConnected ? Colors.green : Colors.red;
    final statusText = isConnected ? 'Connected' : 'Disconnected';

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              size: 64,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBypassStatusCard(BuildContext context, SettingsProvider settingsProvider) {
    final bypassSubnets = settingsProvider.bypassSubnets;
    final bypassLAN = settingsProvider.bypassLAN;
    final hasBypassRules = bypassSubnets.isNotEmpty || bypassLAN;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasBypassRules ? Icons.route : Icons.vpn_lock,
                  color: hasBypassRules ? Colors.orange : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Routing Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (bypassLAN) ...[
              Row(
                children: [
                  Icon(Icons.home, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'LAN bypass active - Local traffic bypasses VPN',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (bypassSubnets.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.network_check, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '${bypassSubnets.length} custom subnet${bypassSubnets.length > 1 ? 's' : ''} bypassed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (settingsProvider.blockedApps.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.block, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    '${settingsProvider.blockedApps.length} app${settingsProvider.blockedApps.length > 1 ? 's' : ''} bypassing VPN',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (!hasBypassRules) ...[
              Row(
                children: [
                  const Icon(Icons.vpn_lock, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'All traffic through VPN',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConnectDialog(BuildContext context, V2RayProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a configuration'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: provider.savedConfigs.length,
            itemBuilder: (context, index) {
              final config = provider.savedConfigs[index];
              return ListTile(
                title: Text(config.remark),
                onTap: () {
                  Navigator.of(context).pop();
                  _connect(context, provider, config);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _connect(BuildContext context, V2RayProvider provider, config) async {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await provider.connect(config, settingsProvider: settingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${config.remark}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.errorConnectionFailed)),
        );
      }
    }
  }

  void _disconnect(BuildContext context, V2RayProvider provider) async {
    try {
      await provider.disconnect();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disconnected')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to disconnect')),
        );
      }
    }
  }
}