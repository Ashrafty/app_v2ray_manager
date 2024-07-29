import 'package:flutter/material.dart';
import '../widgets/traffic_chart.dart';

class TrafficStatsScreen extends StatelessWidget {
  const TrafficStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TrafficChart(),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Total Upload'),
                trailing: Text('100 MB'), // Replace with actual data
              ),
              ListTile(
                title: const Text('Total Download'),
                trailing: Text('200 MB'), // Replace with actual data
              ),
              ListTile(
                title: const Text('Current Speed'),
                trailing: Text('1.5 MB/s'), // Replace with actual data
              ),
            ],
          ),
        ),
      ],
    );
  }
}