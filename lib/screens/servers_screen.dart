import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/v2ray_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/v2ray_config_card.dart';
import '../models/v2ray_config.dart';
import '../utils/constants.dart';
import 'add_configuration_screen.dart';
import 'edit_configuration_screen.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddConfiguration(context),
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
                showDelay: true,
                onConnect: () => _connectToServer(context, v2rayProvider, config),
                onEdit: () => _navigateToEditConfiguration(context, config),
                onDelete: () => _deleteConfig(context, v2rayProvider, config),
                onExport: () => _exportConfig(context, v2rayProvider, config),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToAddConfiguration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddConfigurationScreen(),
      ),
    );
  }

  void _navigateToEditConfiguration(BuildContext context, V2RayConfig config) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditConfigurationScreen(config: config),
      ),
    );
  }

  void _connectToServer(BuildContext context, V2RayProvider provider, V2RayConfig config) async {
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
            onPressed: () async {
              final provider = Provider.of<V2RayProvider>(context, listen: false);
              try {
                await provider.importConfig(textController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration imported successfully')),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error importing configuration: $error')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _exportConfig(BuildContext context, V2RayProvider provider, V2RayConfig config) {
    try {
      final shareLink = provider.exportConfig(config);

      // Copy to clipboard
      Clipboard.setData(ClipboardData(text: shareLink));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuration copied to clipboard'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              _showShareLinkDialog(context, shareLink);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting configuration: $e')),
      );
    }
  }

  void _showShareLinkDialog(BuildContext context, String shareLink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You can share this link with others:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                shareLink,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy Again'),
          ),
        ],
      ),
    );
  }
}