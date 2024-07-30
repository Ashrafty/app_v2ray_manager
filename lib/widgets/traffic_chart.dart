// traffic_chart.dart
import 'package:flutter/material.dart';
import '../models/traffic_stats.dart';

class TrafficChart extends StatelessWidget {
  final List<TrafficStats> stats;

  const TrafficChart({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrafficChartPainter(stats: stats),
      size: Size.infinite,
    );
  }
}

class _TrafficChartPainter extends CustomPainter {
  final List<TrafficStats> stats;

  _TrafficChartPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final uploadPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final downloadPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final uploadPath = Path();
    final downloadPath = Path();

    final maxStats = stats.length > 60 ? 60 : stats.length;
    final xStep = size.width / (maxStats - 1);

    int maxBytes = 0;
    for (var stat in stats.sublist(stats.length - maxStats)) {
      if (stat.uploadBytes > maxBytes) maxBytes = stat.uploadBytes;
      if (stat.downloadBytes > maxBytes) maxBytes = stat.downloadBytes;
    }

    for (int i = 0; i < maxStats; i++) {
      final stat = stats[stats.length - maxStats + i];
      final x = i * xStep;
      final uploadY = size.height - (stat.uploadBytes / maxBytes * size.height);
      final downloadY = size.height - (stat.downloadBytes / maxBytes * size.height);

      if (i == 0) {
        uploadPath.moveTo(x, uploadY);
        downloadPath.moveTo(x, downloadY);
      } else {
        uploadPath.lineTo(x, uploadY);
        downloadPath.lineTo(x, downloadY);
      }
    }

    canvas.drawPath(uploadPath, uploadPaint);
    canvas.drawPath(downloadPath, downloadPaint);

    // Draw legend
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final uploadLegend = 'Upload';
    final downloadLegend = 'Download';

    textPainter.text = TextSpan(text: uploadLegend, style: TextStyle(color: Colors.blue));
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

    textPainter.text = TextSpan(text: downloadLegend, style: TextStyle(color: Colors.red));
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 30));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}