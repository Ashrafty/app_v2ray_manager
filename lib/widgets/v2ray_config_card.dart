import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/v2ray_config.dart';
import '../providers/v2ray_provider.dart';

class V2RayConfigCard extends StatefulWidget {
  final V2RayConfig config;
  final VoidCallback? onConnect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;
  final bool showDelay;

  const V2RayConfigCard({
    super.key,
    required this.config,
    this.onConnect,
    this.onEdit,
    this.onDelete,
    this.onExport,
    this.showDelay = false,
  });

  @override
  State<V2RayConfigCard> createState() => _V2RayConfigCardState();
}

class _V2RayConfigCardState extends State<V2RayConfigCard> {
  int? _delay;
  bool _isTestingDelay = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.config.remark),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.config.address}:${widget.config.port}'),
                if (widget.showDelay) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (_isTestingDelay)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _delay != null ? Icons.signal_cellular_4_bar : Icons.signal_cellular_off,
                          size: 16,
                          color: _getDelayColor(),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isTestingDelay
                            ? 'Testing...'
                            : _delay != null
                                ? '${_delay}ms'
                                : 'Timeout',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDelayColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showDelay)
                  IconButton(
                    icon: const Icon(Icons.speed),
                    onPressed: _isTestingDelay ? null : _testDelay,
                    tooltip: 'Test Delay',
                  ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: widget.onConnect,
                  tooltip: 'Connect',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: widget.onExport,
                  tooltip: 'Export',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDelayColor() {
    if (_delay == null) return Colors.red;
    if (_delay! < 100) return Colors.green;
    if (_delay! < 300) return Colors.orange;
    return Colors.red;
  }

  Future<void> _testDelay() async {
    setState(() {
      _isTestingDelay = true;
      _delay = null;
    });

    try {
      final provider = Provider.of<V2RayProvider>(context, listen: false);
      final delay = await provider.getServerDelay(widget.config);

      if (mounted) {
        setState(() {
          _delay = delay;
          _isTestingDelay = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _delay = null;
          _isTestingDelay = false;
        });
      }
    }
  }
}