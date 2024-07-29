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
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _showImportDialog(context),
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
                onExport: () => _exportConfig(context, v2rayProvider, config),
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

  void _showImportDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Configuration'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter configuration URL'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Import'),
            onPressed: () {
              final provider = Provider.of<V2RayProvider>(context, listen: false);
              provider.importConfig(textController.text).then((_) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration imported successfully')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error importing configuration: $error')),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  void _exportConfig(BuildContext context, V2RayProvider provider, V2RayConfig config) {
    final shareLink = provider.exportConfig(config);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration exported: $shareLink'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // TODO: Implement clipboard functionality
          },
        ),
      ),
    );
  }
}