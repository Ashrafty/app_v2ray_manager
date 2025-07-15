import 'package:flutter/material.dart';
import '../models/v2ray_config.dart';

class V2RayConfigForm extends StatefulWidget {
  final V2RayConfig? initialConfig;
  final Function(V2RayConfig) onSave;
  final bool isLoading;

  const V2RayConfigForm({
    super.key,
    this.initialConfig,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<V2RayConfigForm> createState() => _V2RayConfigFormState();
}

class _V2RayConfigFormState extends State<V2RayConfigForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _remarkController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  late TextEditingController _userIdController;
  late TextEditingController _alterIdController;
  late TextEditingController _securityController;
  late TextEditingController _networkController;

  // Security options
  final List<String> _securityOptions = ['auto', 'aes-128-gcm', 'chacha20-poly1305', 'none'];

  // Network options
  final List<String> _networkOptions = ['tcp', 'ws', 'h2', 'quic', 'grpc'];

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.initialConfig?.remark ?? '');
    _addressController = TextEditingController(text: widget.initialConfig?.address ?? '');
    _portController = TextEditingController(text: widget.initialConfig?.port.toString() ?? '');
    _userIdController = TextEditingController(text: widget.initialConfig?.userId ?? '');
    _alterIdController = TextEditingController(text: widget.initialConfig?.alterId ?? '0');
    _securityController = TextEditingController(text: widget.initialConfig?.security ?? 'auto');
    _networkController = TextEditingController(text: widget.initialConfig?.network ?? 'tcp');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Remark field
          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(
              labelText: 'Remark *',
              hintText: 'Enter a friendly name for this server',
              prefixIcon: Icon(Icons.label_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a remark';
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Address field
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Server Address *',
              hintText: 'example.com or 192.168.1.1',
              prefixIcon: Icon(Icons.dns_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter server address';
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Port field
          TextFormField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'Port *',
              hintText: '443, 80, 8080, etc.',
              prefixIcon: Icon(Icons.router_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter port number';
              }
              final port = int.tryParse(value);
              if (port == null || port < 1 || port > 65535) {
                return 'Please enter a valid port (1-65535)';
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // User ID field
          TextFormField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID *',
              hintText: 'UUID provided by your service provider',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter user ID';
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Alter ID field
          TextFormField(
            controller: _alterIdController,
            decoration: const InputDecoration(
              labelText: 'Alter ID',
              hintText: 'Usually 0 for newer configurations',
              prefixIcon: Icon(Icons.numbers_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final alterId = int.tryParse(value);
                if (alterId == null || alterId < 0) {
                  return 'Please enter a valid alter ID (0 or positive number)';
                }
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Security dropdown
          DropdownButtonFormField<String>(
            value: _securityController.text.isNotEmpty ? _securityController.text : 'auto',
            decoration: const InputDecoration(
              labelText: 'Security',
              prefixIcon: Icon(Icons.security_outlined),
              border: OutlineInputBorder(),
            ),
            items: _securityOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: widget.isLoading ? null : (String? newValue) {
              if (newValue != null) {
                _securityController.text = newValue;
              }
            },
          ),

          const SizedBox(height: 16),

          // Network dropdown
          DropdownButtonFormField<String>(
            value: _networkController.text.isNotEmpty ? _networkController.text : 'tcp',
            decoration: const InputDecoration(
              labelText: 'Network',
              prefixIcon: Icon(Icons.network_check_outlined),
              border: OutlineInputBorder(),
            ),
            items: _networkOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            onChanged: widget.isLoading ? null : (String? newValue) {
              if (newValue != null) {
                _networkController.text = newValue;
              }
            },
          ),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: widget.isLoading ? null : _handleSave,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(widget.isLoading ? 'Saving...' : 'Save Configuration'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      try {
        final config = V2RayConfig(
          remark: _remarkController.text.trim(),
          address: _addressController.text.trim(),
          port: int.parse(_portController.text.trim()),
          userId: _userIdController.text.trim(),
          alterId: _alterIdController.text.trim().isEmpty ? '0' : _alterIdController.text.trim(),
          security: _securityController.text.trim(),
          network: _networkController.text.trim(),
        );
        widget.onSave(config);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _userIdController.dispose();
    _alterIdController.dispose();
    _securityController.dispose();
    _networkController.dispose();
    super.dispose();
  }
}