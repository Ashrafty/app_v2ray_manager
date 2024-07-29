import 'package:flutter/material.dart';
import '../models/v2ray_config.dart';

class V2RayConfigCard extends StatelessWidget {
  final V2RayConfig config;
  final VoidCallback? onConnect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const V2RayConfigCard({
    Key? key,
    required this.config,
    this.onConnect,
    this.onEdit,
    this.onDelete,
    this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(config.remark),
        subtitle: Text(config.address),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onConnect,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: onExport,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}