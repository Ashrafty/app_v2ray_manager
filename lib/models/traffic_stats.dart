class TrafficStats {
  final int uploadBytes;
  final int downloadBytes;
  final DateTime timestamp;

  TrafficStats({
    required this.uploadBytes,
    required this.downloadBytes,
    required this.timestamp,
  });

  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      uploadBytes: json['uploadBytes'],
      downloadBytes: json['downloadBytes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadBytes': uploadBytes,
      'downloadBytes': downloadBytes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get totalTraffic {
    final total = uploadBytes + downloadBytes;
    if (total < 1024) {
      return '$total B';
    } else if (total < 1024 * 1024) {
      return '${(total / 1024).toStringAsFixed(2)} KB';
    } else if (total < 1024 * 1024 * 1024) {
      return '${(total / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(total / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}