import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_info.dart';
import '../services/app_discovery_service.dart';

class BlockedAppsScreen extends StatefulWidget {
  const BlockedAppsScreen({super.key});

  @override
  State<BlockedAppsScreen> createState() => _BlockedAppsScreenState();
}

class _BlockedAppsScreenState extends State<BlockedAppsScreen> {
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  bool _isLoading = true;
  bool _includeSystemApps = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apps = await AppDiscoveryService.getInstalledApps(
        includeSystemApps: _includeSystemApps,
      );
      
      setState(() {
        _allApps = apps;
        _filteredApps = apps;
        _isLoading = false;
      });
      
      _filterApps();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading apps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterApps() {
    setState(() {
      _filteredApps = _allApps.where((app) {
        final matchesSearch = _searchQuery.isEmpty ||
            app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesSearch;
      }).toList();

      // Sort apps: blocked first, then alphabetically
      _filteredApps.sort((a, b) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final aBlocked = settingsProvider.blockedApps.contains(a.packageName);
        final bBlocked = settingsProvider.blockedApps.contains(b.packageName);

        if (aBlocked && !bBlocked) return -1;
        if (!aBlocked && bBlocked) return 1;
        return a.appName.compareTo(b.appName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Column(
            children: [
              // Search and filters
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _filterApps();
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterApps();
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Filter options
                    Row(
                      children: [
                        // System apps toggle
                        FilterChip(
                          label: const Text('Include System Apps'),
                          selected: _includeSystemApps,
                          onSelected: (selected) {
                            setState(() {
                              _includeSystemApps = selected;
                            });
                            _loadApps();
                          },
                        ),

                        const Spacer(),

                        // App count indicator
                        Text(
                          '${_filteredApps.length} apps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _buildAllAppsTab(settingsProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.blockedApps.isEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () => _clearAllBlockedApps(settingsProvider),
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            backgroundColor: Colors.red,
          );
        },
      ),
    );
  }

  Widget _buildAllAppsTab(SettingsProvider settingsProvider) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading installed apps...'),
          ],
        ),
      );
    }

    if (_filteredApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No apps found matching "$_searchQuery"' : 'No apps found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        final isBlocked = settingsProvider.blockedApps.contains(app.packageName);
        final canBlock = AppDiscoveryService.canBlockApp(app);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildAppIcon(app),
            title: Text(
              app.appName,
              style: TextStyle(
                fontWeight: isBlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.packageName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: app.category == AppCategory.system
                            ? Colors.grey.withValues(alpha: 0.2)
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${app.category.icon} ${app.category.displayName}',
                        style: TextStyle(
                          fontSize: 10,
                          color: app.category == AppCategory.system
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (app.isSystemApp) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SYSTEM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: canBlock
                ? Switch(
                    value: isBlocked,
                    onChanged: (value) => _toggleAppBlock(settingsProvider, app, value),
                  )
                : Icon(
                    Icons.lock,
                    color: Colors.grey.withValues(alpha: 0.5),
                    size: 20,
                  ),
            onTap: canBlock ? () => _toggleAppBlock(settingsProvider, app, !isBlocked) : null,
          ),
        );
      },
    );
  }



  Widget _buildAppIcon(AppInfo app, {double size = 40}) {
    if (app.icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          app.icon!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(app, size),
        ),
      );
    }
    return _buildDefaultIcon(app, size);
  }

  Widget _buildDefaultIcon(AppInfo app, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          app.category.icon,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  void _toggleAppBlock(SettingsProvider provider, AppInfo app, bool block) async {
    if (!AppDiscoveryService.canBlockApp(app)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot block system app: ${app.appName}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newList = List<String>.from(provider.blockedApps);

    if (block) {
      if (!newList.contains(app.packageName)) {
        newList.add(app.packageName);
      }
    } else {
      newList.remove(app.packageName);
    }

    await provider.setBlockedApps(newList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            block
                ? '${app.appName} will bypass VPN'
                : '${app.appName} will use VPN',
          ),
          backgroundColor: block ? Colors.orange : Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }



  void _clearAllBlockedApps(SettingsProvider provider) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Blocked Apps'),
        content: const Text(
          'Are you sure you want to unblock all apps?\n\n'
          'All apps will use the VPN connection.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
            onPressed: () async {
              await provider.setBlockedApps([]);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All apps unblocked - will use VPN'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blocked Apps Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What are Blocked Apps?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Blocked apps will bypass the VPN tunnel and use your direct internet connection. This is useful for apps that don\'t work well with VPN or need local network access.',
              ),
              SizedBox(height: 16),
              Text(
                'When to Block Apps:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Banking apps that detect VPN usage\n'
                '• Local network apps (printers, NAS)\n'
                '• Apps with geo-restrictions\n'
                '• Games with anti-VPN measures\n'
                '• Apps that need fastest connection',
              ),
              SizedBox(height: 16),
              Text(
                'Security Note:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                'Blocked apps will not have VPN protection. Their traffic will be visible to your ISP and network administrators.',
                style: TextStyle(color: Colors.orange),
              ),
              SizedBox(height: 16),
              Text(
                'How to Use:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Toggle individual apps on/off\n'
                '• Use categories for bulk selection\n'
                '• Search for specific apps\n'
                '• System apps marked with lock cannot be blocked',
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
}
