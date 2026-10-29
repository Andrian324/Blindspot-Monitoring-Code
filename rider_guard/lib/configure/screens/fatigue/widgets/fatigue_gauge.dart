import 'package:flutter/material.dart';
import 'dart:math';
import '../../../theme/app_theme.dart';

class FatigueGauge extends StatelessWidget {
  final int durationSeconds;
  final String level;

  const FatigueGauge({
    super.key,
    required this.durationSeconds,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: _GaugePainter(durationSeconds: durationSeconds),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(durationSeconds),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'DURASI BERKENDARA',
                style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _levelColor(level).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _levelColor(level).withValues(alpha: 0.4)),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: _levelColor(level),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          // Zone labels
          Positioned(bottom: 24, left: 20,
            child: Text('NORMAL', style: TextStyle(
              color: AppTheme.accentGreen.withValues(alpha: 0.7), fontSize: 9))),
          Positioned(bottom: 24, right: 20,
            child: Text('KRITIS', style: TextStyle(
              color: AppTheme.accentRed.withValues(alpha: 0.7), fontSize: 9))),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'KRITIS': return AppTheme.accentRed;
      case 'LELAH': return AppTheme.accentOrange;
      case 'WASPADA': return AppTheme.accentYellow;
      default: return AppTheme.accentGreen;
    }
  }

  String _formatTime(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _GaugePainter extends CustomPainter {
  final int durationSeconds;
  static const int maxSeconds = 1800; // 30 minutes = critical

  _GaugePainter({required this.durationSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Background track
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
      startAngle, sweepAngle, false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.borderColor,
    );

    // Progress
    final progress = (durationSeconds / maxSeconds).clamp(0.0, 1.0);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        AppTheme.accentGreen,
        AppTheme.accentYellow,
        AppTheme.accentOrange,
        AppTheme.accentRed,
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(
          Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2));

    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
      startAngle, sweepAngle * progress, false,
      paint,
    );

    // Milestone ticks (10min, 15min, 30min)
    final milestones = [600, 900, 1800];
    for (final ms in milestones) {
      final angle = startAngle + sweepAngle * (ms / maxSeconds);
      final tx = cx + (r + 8) * cos(angle);
      final ty = cy + (r + 8) * sin(angle);
      canvas.drawCircle(Offset(tx, ty), 3,
        Paint()..color = AppTheme.textSecondary.withValues(alpha: 0.5));
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.durationSeconds != durationSeconds;
}