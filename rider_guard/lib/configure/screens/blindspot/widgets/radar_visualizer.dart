import 'package:flutter/material.dart';
import 'dart:math';
import '../../../models/blindspot_model.dart';
import '../../../theme/app_theme.dart';

class RadarVisualizer extends StatelessWidget {
  final BlindspotData? data;
  const RadarVisualizer({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Stack(
        children: [
          // Title
          Positioned(
            top: 12, left: 16,
            child: Text('TAMPILAN RADAR', style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.5,
            )),
          ),
          // Radar painter
          Positioned.fill(
            child: CustomPaint(
              painter: _RadarPainter(data: data),
            ),
          ),
          // Labels
          Positioned(bottom: 12, left: 20,
            child: _StatusBadge('KIRI', data?.hazardLeft ?? 0)),
          Positioned(bottom: 12, right: 20,
            child: _StatusBadge('KANAN', data?.hazardRight ?? 0)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String side;
  final int level;
  const _StatusBadge(this.side, this.level);

  Color get _color {
    switch (level) {
      case 2: return AppTheme.accentRed;
      case 1: return AppTheme.accentYellow;
      default: return AppTheme.accentGreen;
    }
  }

  String get _label => BlindspotData.hazardLabel(level);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _color)),
          const SizedBox(width: 6),
          Text('$side: $_label',
            style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final BlindspotData? data;
  _RadarPainter({this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.7;

    // Draw FOV arcs (60 degree FOV)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppTheme.accentBlue.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final r = (size.height * 0.55) * (i / 4);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
        pi + (pi / 6), // -150 degrees (60 deg FOV from back)
        -pi * 2 / 3,   // actually sweep 120 degrees upward
        false,
        arcPaint,
      );
    }

    // Draw FOV boundary lines (±30 degrees from straight back)
    final linePaint = Paint()
      ..color = AppTheme.accentBlue.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    final maxR = size.height * 0.55;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx - maxR * sin(pi / 6), cy - maxR * cos(pi / 6)),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + maxR * sin(pi / 6), cy - maxR * cos(pi / 6)),
      linePaint,
    );

    // Draw motorcycle icon at center
    _drawMotoIcon(canvas, cx, cy);

    // Draw detected object if exists
    if (data != null && data!.distance > 0) {
      _drawObject(canvas, size, cx, cy, data!);
    }

    // Zone labels
    _drawZoneLabels(canvas, cx, cy, size);
  }

  void _drawMotoIcon(Canvas canvas, double cx, double cy) {
    final paint = Paint()
      ..color = AppTheme.accentBlue
      ..style = PaintingStyle.fill;

    // Simple motorcycle top view
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 16, height: 30),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, paint);

    // Wheels
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 18), width: 10, height: 14),
      paint..color = AppTheme.accentBlue.withValues(alpha: 0.7),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 10, height: 14),
      paint,
    );
  }

  void _drawObject(Canvas canvas, Size size, double cx, double cy, BlindspotData data) {
    final maxDist = 4.0; // meter
    final maxR = size.height * 0.52;

    // Map distance to radius (inverted: closer = closer to center)
    final r = (data.distance / maxDist) * maxR;

    // Map posX to angle offset
    // posX in mm: -800 ~ +800, map to ±30 degrees
    final angle = (data.posX / 800.0) * (pi / 6);

    final objX = cx + r * sin(angle);
    final objY = cy - r * cos(angle);

    final color = _hazardColor(data.hazardLeft == 2 || data.hazardRight == 2 ? 2
        : data.hazardLeft == 1 || data.hazardRight == 1 ? 1 : 0);

    // Glow effect
    canvas.drawCircle(
      Offset(objX, objY), 16,
      Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(objX, objY), 8,
      Paint()..color = color.withValues(alpha: 0.5)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(objX, objY), 5,
      Paint()..color = color..style = PaintingStyle.fill,
    );

    // Distance label
    final tp = TextPainter(
      text: TextSpan(
        text: '${data.distance.toStringAsFixed(1)}m',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(objX - tp.width / 2, objY - 22));
  }

  void _drawZoneLabels(Canvas canvas, double cx, double cy, Size size) {
    final labels = ['1m', '2m', '3m', '4m'];
    final maxR = size.height * 0.55;
    for (int i = 0; i < labels.length; i++) {
      final r = maxR * ((i + 1) / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx + 4, cy - r + 2));
    }
  }

  Color _hazardColor(int level) {
    switch (level) {
      case 2: return AppTheme.accentRed;
      case 1: return AppTheme.accentYellow;
      default: return AppTheme.accentGreen;
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => oldDelegate.data != data;
}