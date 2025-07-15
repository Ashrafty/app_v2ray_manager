import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/logs_provider.dart';
import '../models/log_entry.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearLogsDialog(context),
          ),
          PopupMenuButton<LogLevel?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (level) => _filterLogs(context, level),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Logs'),
              ),
              const PopupMenuItem(
                value: LogLevel.error,
                child: Text('Errors Only'),
              ),
              const PopupMenuItem(
                value: LogLevel.warning,
                child: Text('Warnings Only'),
              ),
              const PopupMenuItem(
                value: LogLevel.success,
                child: Text('Success Only'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LogsProvider>(
        builder: (context, logsProvider, child) {
          final logs = logsProvider.logs;

          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No logs available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect to a server to see logs',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogTile(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogTile(LogEntry log) {
    Color levelColor;
    switch (log.level) {
      case LogLevel.error:
        levelColor = Colors.red;
        break;
      case LogLevel.warning:
        levelColor = Colors.orange;
        break;
      case LogLevel.success:
        levelColor = Colors.green;
        break;
      case LogLevel.info:
        levelColor = Colors.blue;
        break;
      case LogLevel.debug:
        levelColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: levelColor.withValues(alpha: 0.1),
          child: Text(
            log.levelIcon,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          log.message,
          style: TextStyle(
            fontWeight: log.level == LogLevel.error ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.formattedTimestamp,
              style: const TextStyle(fontSize: 12),
            ),
            if (log.serverRemark != null)
              Text(
                'Server: ${log.serverRemark}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            log.level.toString().split('.').last.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: levelColor.withValues(alpha: 0.1),
          side: BorderSide(color: levelColor, width: 1),
        ),
      ),
    );
  }

  void _showClearLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<LogsProvider>(context, listen: false).clearLogs();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _filterLogs(BuildContext context, LogLevel? level) {
    // This could be implemented with a filter state in the provider
    // For now, we'll show a snackbar indicating the filter
    final message = level == null ? 'Showing all logs' : 'Filtering by ${level.toString().split('.').last}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}