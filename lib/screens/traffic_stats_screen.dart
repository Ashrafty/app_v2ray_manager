// traffic_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_stats_provider.dart';
import '../models/traffic_stats.dart';
import '../widgets/traffic_chart.dart';

class TrafficStatsScreen extends StatelessWidget {
  const TrafficStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrafficStatsProvider>(
      builder: (context, trafficStatsProvider, child) {
        final stats = trafficStatsProvider.stats;
        final latestStat = stats.isNotEmpty ? stats.last : null;

        return Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: TrafficChart(stats: stats),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildStatTile('Total Upload', _formatBytes(latestStat?.uploadBytes ?? 0)),
                  _buildStatTile('Total Download', _formatBytes(latestStat?.downloadBytes ?? 0)),
                  _buildStatTile('Total Traffic', latestStat?.totalTraffic ?? 'N/A'),
                  _buildStatTile('Current Upload Speed', _calculateSpeed(stats, true)),
                  _buildStatTile('Current Download Speed', _calculateSpeed(stats, false)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _calculateSpeed(List<TrafficStats> stats, bool isUpload) {
    if (stats.length < 2) return 'N/A';
    
    final latest = stats.last;
    final previous = stats[stats.length - 2];
    final timeDiff = latest.timestamp.difference(previous.timestamp).inSeconds;
    
    if (timeDiff == 0) return 'N/A';

    final bytesDiff = isUpload
        ? latest.uploadBytes - previous.uploadBytes
        : latest.downloadBytes - previous.downloadBytes;

    final speedBps = bytesDiff / timeDiff;

    return _formatBytes(speedBps.round()) + '/s';
  }
}
