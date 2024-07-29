import 'dart:math';

import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/traffic_stats.dart';

class TrafficStatsProvider with ChangeNotifier {
  List<TrafficStats> _stats = [];
  Timer? _updateTimer;

  List<TrafficStats> get stats => _stats;

  TrafficStatsProvider() {
    _startUpdating();
  }

  void _startUpdating() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStats();
    });
  }

  void _updateStats() {
    // TODO: Implement actual stats fetching from V2Ray
    final newStat = TrafficStats(
      uploadBytes: (_stats.lastOrNull?.uploadBytes ?? 0) + (100 + Random().nextInt(900)),
      downloadBytes: (_stats.lastOrNull?.downloadBytes ?? 0) + (100 + Random().nextInt(900)),
      timestamp: DateTime.now(),
    );
    _stats.add(newStat);
    if (_stats.length > 60) {
      _stats.removeAt(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}