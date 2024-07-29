import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_stats_provider.dart';
import '../widgets/traffic_chart.dart';

class TrafficStatsScreen extends StatelessWidget {
  const TrafficStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TrafficStatsProvider>(
      builder: (context, trafficStatsProvider, child) {
        final latestStats = trafficStatsProvider.stats.lastOrNull;
        return Column(
          children: [
            const TrafficChart(),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Total Upload'),
                    trailing: Text(latestStats?.uploadBytes.toString() ?? '0 B'),
                  ),
                  ListTile(
                    title: const Text('Total Download'),
                    trailing: Text(latestStats?.downloadBytes.toString() ?? '0 B'),
                  ),
                  ListTile(
                    title: const Text('Current Speed'),
                    trailing: Text('${latestStats?.totalTraffic ?? '0 B'}/s'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}