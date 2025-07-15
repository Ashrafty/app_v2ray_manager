class LogEntry {
  final String message;
  final DateTime timestamp;
  final LogLevel level;
  final String? serverRemark;

  LogEntry({
    required this.message,
    required this.timestamp,
    required this.level,
    this.serverRemark,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (e) => e.toString() == 'LogLevel.${json['level']}',
        orElse: () => LogLevel.info,
      ),
      serverRemark: json['serverRemark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString().split('.').last,
      'serverRemark': serverRemark,
    };
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get levelIcon {
    switch (level) {
      case LogLevel.error:
        return '❌';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.debug:
        return '🔍';
      case LogLevel.success:
        return '✅';
    }
  }
}

enum LogLevel {
  error,
  warning,
  info,
  debug,
  success,
}
