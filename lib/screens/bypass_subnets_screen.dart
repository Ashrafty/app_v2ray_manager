import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/subnet_validator.dart';

class BypassSubnetsScreen extends StatefulWidget {
  const BypassSubnetsScreen({super.key});

  @override
  State<BypassSubnetsScreen> createState() => _BypassSubnetsScreenState();
}

class _BypassSubnetsScreenState extends State<BypassSubnetsScreen> {
  final _subnetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPresets = false;

  @override
  void dispose() {
    _subnetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bypass Subnets'),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.route_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Bypass Subnet Configuration',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure IP ranges that should bypass the VPN tunnel and use direct routing. This is useful for accessing local network resources.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // LAN bypass status card
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              settingsProvider.bypassLAN ? Icons.home : Icons.vpn_lock,
                              color: settingsProvider.bypassLAN ? Colors.orange : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LAN Bypass Status',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: settingsProvider.bypassLAN,
                              onChanged: (value) => _toggleLANBypass(settingsProvider, value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          settingsProvider.bypassLAN
                              ? 'Local network traffic (192.168.x.x, 10.x.x.x, etc.) automatically bypasses VPN'
                              : 'All traffic goes through VPN tunnel - local devices may not be accessible',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: settingsProvider.bypassLAN ? Colors.orange : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Add subnet form
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Subnet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _subnetController,
                                  decoration: const InputDecoration(
                                    labelText: 'Subnet (CIDR notation)',
                                    hintText: '192.168.1.0/24',
                                    prefixIcon: Icon(Icons.network_check),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a subnet';
                                    }
                                    if (!SubnetValidator.isValidCIDR(value.trim())) {
                                      return 'Invalid CIDR format (e.g., 192.168.1.0/24)';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _addSubnet(settingsProvider),
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Preset subnets toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Common Network Ranges',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showPresets = !_showPresets;
                                });
                              },
                              icon: Icon(_showPresets ? Icons.expand_less : Icons.expand_more),
                              label: Text(_showPresets ? 'Hide' : 'Show'),
                            ),
                          ],
                        ),
                        
                        if (_showPresets) ...[
                          const SizedBox(height: 8),
                          ...SubnetValidator.commonLocalRanges.map((subnet) => 
                            _buildPresetSubnetTile(subnet, settingsProvider)
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Current subnets
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Bypass Subnets',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (settingsProvider.bypassSubnets.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _clearAllSubnets(settingsProvider),
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Clear All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (settingsProvider.bypassSubnets.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.route_outlined,
                                  size: 48,
                                  color: Colors.grey.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No bypass subnets configured',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All traffic will go through the VPN tunnel',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...settingsProvider.bypassSubnets.map((subnet) => 
                            _buildSubnetTile(subnet, settingsProvider)
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubnetTile(String subnet, SettingsProvider provider) {
    final info = SubnetValidator.getSubnetInfo(subnet);
    final description = SubnetValidator.getSubnetDescription(subnet);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: info?.isPrivate == true 
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
          child: Icon(
            info?.isPrivate == true ? Icons.home : Icons.public,
            color: info?.isPrivate == true ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          subnet,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeSubnet(subnet, provider),
          tooltip: 'Remove subnet',
        ),
        onTap: () => _showSubnetDetails(subnet),
      ),
    );
  }

  Widget _buildPresetSubnetTile(String subnet, SettingsProvider provider) {
    final isAdded = provider.bypassSubnets.contains(subnet);
    final description = SubnetValidator.getSubnetDescription(subnet);
    
    return ListTile(
      dense: true,
      leading: Icon(
        isAdded ? Icons.check_circle : Icons.add_circle_outline,
        color: isAdded ? Colors.green : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        subnet,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: isAdded ? null : () => _addPresetSubnet(subnet, provider),
    );
  }

  void _toggleLANBypass(SettingsProvider provider, bool value) async {
    await provider.setBypassLAN(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'LAN bypass enabled - Local network traffic will bypass VPN'
                : 'LAN bypass disabled - All traffic will go through VPN tunnel',
          ),
          backgroundColor: value ? Colors.orange : Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addSubnet(SettingsProvider provider) {
    if (_formKey.currentState!.validate()) {
      final subnet = _subnetController.text.trim();
      final normalizedSubnet = SubnetValidator.normalizeCIDR(subnet);

      if (normalizedSubnet != null) {
        if (!provider.bypassSubnets.contains(normalizedSubnet)) {
          final newList = List<String>.from(provider.bypassSubnets)..add(normalizedSubnet);
          provider.setBypassSubnets(newList);
          _subnetController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added subnet: $normalizedSubnet'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subnet $normalizedSubnet already exists'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _addPresetSubnet(String subnet, SettingsProvider provider) {
    if (!provider.bypassSubnets.contains(subnet)) {
      final newList = List<String>.from(provider.bypassSubnets)..add(subnet);
      provider.setBypassSubnets(newList);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added preset: $subnet'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeSubnet(String subnet, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Subnet'),
        content: Text('Are you sure you want to remove "$subnet" from bypass list?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
            onPressed: () {
              final newList = List<String>.from(provider.bypassSubnets)..remove(subnet);
              provider.setBypassSubnets(newList);
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed subnet: $subnet'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _clearAllSubnets(SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Subnets'),
        content: const Text('Are you sure you want to remove all bypass subnets?\n\nThis will route all traffic through the VPN tunnel.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
            onPressed: () {
              provider.setBypassSubnets([]);
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All bypass subnets cleared'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSubnetDetails(String subnet) {
    final info = SubnetValidator.getSubnetInfo(subnet);
    if (info == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subnet Details: $subnet'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Network Address', info.networkAddress),
              _buildDetailRow('Broadcast Address', info.broadcastAddress),
              _buildDetailRow('Subnet Mask', info.subnetMask),
              _buildDetailRow('Prefix Length', '/${info.prefixLength}'),
              _buildDetailRow('Total Hosts', info.totalHosts.toString()),
              _buildDetailRow('Usable Hosts', info.usableHosts.toString()),
              _buildDetailRow('Network Type', info.isPrivate ? 'Private' : 'Public'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bypass Subnets Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What are Bypass Subnets?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Bypass subnets are IP address ranges that will use direct routing instead of going through the VPN tunnel. This allows you to access local network resources while connected to the VPN.',
              ),
              SizedBox(height: 16),
              Text(
                'When to Use:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Access local network printers, file shares, or devices\n'
                '• Connect to local development servers\n'
                '• Use network-attached storage (NAS)\n'
                '• Access router admin panels\n'
                '• Connect to local IoT devices',
              ),
              SizedBox(height: 16),
              Text(
                'CIDR Notation Examples:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• 192.168.1.0/24 - Single subnet (256 addresses)\n'
                '• 192.168.0.0/16 - All 192.168.x.x addresses\n'
                '• 10.0.0.0/8 - All 10.x.x.x addresses\n'
                '• 172.16.0.0/12 - 172.16.x.x to 172.31.x.x',
                style: TextStyle(fontFamily: 'monospace'),
              ),
              SizedBox(height: 16),
              Text(
                'Security Note:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text(
                'Traffic to bypass subnets will not be encrypted or routed through the VPN. Only add trusted local networks.',
                style: TextStyle(color: Colors.orange),
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
