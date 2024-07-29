import 'package:flutter/material.dart';
import '../models/v2ray_config.dart';

class V2RayConfigForm extends StatefulWidget {
  final V2RayConfig? initialConfig;
  final Function(V2RayConfig) onSave;

  const V2RayConfigForm({Key? key, this.initialConfig, required this.onSave}) : super(key: key);

  @override
  _V2RayConfigFormState createState() => _V2RayConfigFormState();
}

class _V2RayConfigFormState extends State<V2RayConfigForm> {
  late TextEditingController _remarkController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  late TextEditingController _userIdController;
  late TextEditingController _alterIdController;
  late TextEditingController _securityController;
  late TextEditingController _networkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.initialConfig?.remark ?? '');
    _addressController = TextEditingController(text: widget.initialConfig?.address ?? '');
    _portController = TextEditingController(text: widget.initialConfig?.port.toString() ?? '');
    _userIdController = TextEditingController(text: widget.initialConfig?.userId ?? '');
    _alterIdController = TextEditingController(text: widget.initialConfig?.alterId ?? '');
    _securityController = TextEditingController(text: widget.initialConfig?.security ?? 'auto');
    _networkController = TextEditingController(text: widget.initialConfig?.network ?? 'tcp');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _remarkController,
            decoration: const InputDecoration(labelText: 'Remark'),
          ),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          TextField(
            controller: _portController,
            decoration: const InputDecoration(labelText: 'Port'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(labelText: 'User ID'),
          ),
          TextField(
            controller: _alterIdController,
            decoration: const InputDecoration(labelText: 'Alter ID'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _securityController,
            decoration: const InputDecoration(labelText: 'Security'),
          ),
          TextField(
            controller: _networkController,
            decoration: const InputDecoration(labelText: 'Network'),
          ),
          ElevatedButton(
            onPressed: () {
              final config = V2RayConfig(
                remark: _remarkController.text,
                address: _addressController.text,
                port: int.parse(_portController.text),
                userId: _userIdController.text,
                alterId: _alterIdController.text,
                security: _securityController.text,
                network: _networkController.text,
              );
              widget.onSave(config);
            },
            child: const Text('Save Configuration'),
          ),
        ],
      ),
    );
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