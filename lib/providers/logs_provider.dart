import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/log_entry.dart';
import '../utils/constants.dart';

class LogsProvider with ChangeNotifier {
  final List<LogEntry> _logs = [];
  static const int _maxLogEntries = 1000;

  List<LogEntry> get logs => List.unmodifiable(_logs);

  LogsProvider() {
    _loadSavedLogs();
  }

  /// Add a new log entry
  void addLog(String message, LogLevel level, {String? serverRemark}) {
    final logEntry = LogEntry(
      message: message,
      timestamp: DateTime.now(),
      level: level,
      serverRemark: serverRemark,
    );

    _logs.insert(0, logEntry); // Insert at beginning for newest first

    // Keep only the most recent entries
    if (_logs.length > _maxLogEntries) {
      _logs.removeRange(_maxLogEntries, _logs.length);
    }

    _saveLogs();
    notifyListeners();
  }

  /// Log connection events
  void logConnection(String serverRemark) {
    addLog('Connected to server', LogLevel.success, serverRemark: serverRemark);
  }

  void logDisconnection() {
    addLog('Disconnected from server', LogLevel.info);
  }

  void logConnectionError(String error, {String? serverRemark}) {
    addLog('Connection failed: $error', LogLevel.error, serverRemark: serverRemark);
  }

  void logServerDelay(String serverRemark, int delay) {
    addLog('Server delay: ${delay}ms', LogLevel.info, serverRemark: serverRemark);
  }

  void logServerDelayError(String serverRemark, String error) {
    addLog('Failed to get server delay: $error', LogLevel.warning, serverRemark: serverRemark);
  }

  void logConfigImport(String serverRemark) {
    addLog('Configuration imported: $serverRemark', LogLevel.success);
  }

  void logConfigImportError(String error) {
    addLog('Failed to import configuration: $error', LogLevel.error);
  }

  void logStatusChange(String status, {String? serverRemark}) {
    addLog('Status changed to: $status', LogLevel.info, serverRemark: serverRemark);
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
    _saveLogs();
    notifyListeners();
  }

  /// Filter logs by level
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Filter logs by server
  List<LogEntry> getLogsByServer(String serverRemark) {
    return _logs.where((log) => log.serverRemark == serverRemark).toList();
  }

  /// Get logs from the last N hours
  List<LogEntry> getRecentLogs(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _logs.where((log) => log.timestamp.isAfter(cutoff)).toList();
  }

  /// Save logs to persistent storage
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _logs.take(100).map((log) => jsonEncode(log.toJson())).toList(); // Save only last 100 logs
      await prefs.setStringList(AppConstants.prefKeyLogs, logsJson);
    } catch (e) {
      debugPrint('Failed to save logs: $e');
    }
  }

  /// Load logs from persistent storage
  Future<void> _loadSavedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLogsJson = prefs.getStringList(AppConstants.prefKeyLogs) ?? [];
      
      _logs.clear();
      for (final logJson in savedLogsJson) {
        try {
          final logData = jsonDecode(logJson);
          _logs.add(LogEntry.fromJson(logData));
        } catch (e) {
          debugPrint('Failed to parse log entry: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load logs: $e');
    }
  }
}
