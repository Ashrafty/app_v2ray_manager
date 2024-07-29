import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/v2ray_provider.dart';
import '../widgets/v2ray_config_card.dart';
import '../widgets/v2ray_config_form.dart';
import '../models/v2ray_config.dart';
import '../utils/constants.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddConfigDialog(context),
          ),
        ],
      ),
      body: Consumer<V2RayProvider>(
        builder: (context, v2rayProvider, child) {
          if (v2rayProvider.savedConfigs.isEmpty) {
            return const Center(
              child: Text(AppConstants.errorNoConfigs),
            );
          }
          return ListView.builder(
            itemCount: v2rayProvider.savedConfigs.length,
            itemBuilder: (context, index) {
              final config = v2rayProvider.savedConfigs[index];
              return V2RayConfigCard(
                config: config,
                onConnect: () => _connectToServer(context, v2rayProvider, config),
                onEdit: () => _showEditConfigDialog(context, v2rayProvider, config),
                onDelete: () => _deleteConfig(context, v2rayProvider, config),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Configuration'),
        content: V2RayConfigForm(
          onSave: (config) {
            Provider.of<V2RayProvider>(context, listen: false).addConfig(config);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showEditConfigDialog(BuildContext context, V2RayProvider provider, V2RayConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Configuration'),
        content: V2RayConfigForm(
          initialConfig: config,
          onSave: (newConfig) {
            provider.updateConfig(config, newConfig);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _connectToServer(BuildContext context, V2RayProvider provider, V2RayConfig config) async {
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

  void _deleteConfig(BuildContext context, V2RayProvider provider, V2RayConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete ${config.remark}?'),
        actions: [
          TextButton(
            child: const Text(AppConstants.buttonCancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(AppConstants.buttonDelete),
            onPressed: () {
              provider.removeConfig(config);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}