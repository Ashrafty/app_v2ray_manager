import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/v2ray_provider.dart';
import '../widgets/v2ray_config_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<V2RayProvider>(
      builder: (context, v2rayProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                v2rayProvider.isConnected ? 'Connected' : 'Disconnected',
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(height: 20),
              if (v2rayProvider.isConnected)
                V2RayConfigCard(config: v2rayProvider.currentConfig!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: v2rayProvider.isConnected
                    ? () => _disconnect(context, v2rayProvider)
                    : () => _showConnectDialog(context, v2rayProvider),
                child: Text(v2rayProvider.isConnected
                    ? AppConstants.buttonDisconnect
                    : AppConstants.buttonConnect),
              ),
            ],
          ),
        );
      },
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
      await provider.connect(config);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${config.remark}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.errorConnectionFailed)),
      );
    }
  }

  void _disconnect(BuildContext context, V2RayProvider provider) async {
    try {
      await provider.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to disconnect')),
      );
    }
  }
}