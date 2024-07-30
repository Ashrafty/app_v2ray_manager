import 'dart:async';
import 'package:flutter/foundation.dart';
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
    final now = DateTime.now();
    final newStat = TrafficStats(
      uploadBytes: (_stats.lastOrNull?.uploadBytes ?? 0) + (100 + (now.second * 10)),
      downloadBytes: (_stats.lastOrNull?.downloadBytes ?? 0) + (200 + (now.second * 20)),
      timestamp: now,
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
