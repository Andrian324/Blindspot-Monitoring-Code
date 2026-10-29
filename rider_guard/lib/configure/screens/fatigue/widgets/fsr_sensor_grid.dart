import 'package:flutter/material.dart';
import '../../../models/fatigue_model.dart';
import '../../../theme/app_theme.dart';

class FsrSensorGrid extends StatelessWidget {
  final FatigueData data;
  const FsrSensorGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SENSOR TEKANAN FSR',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        // Seat layout (2x2 grid representing seat zones)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              // Seat schematic label
              const Text('KURSI MOTOR (Tampak Atas)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _FsrCell(
                    label: 'S1', sublabel: 'Kiri Depan',
                    value: data.sensor1, pin: 32)),
                  const SizedBox(width: 10),
                  Expanded(child: _FsrCell(
                    label: 'S2', sublabel: 'Kanan Depan',
                    value: data.sensor2, pin: 34)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _FsrCell(
                    label: 'S3', sublabel: 'Kiri Belakang',
                    value: data.sensor3, pin: 35)),
                  const SizedBox(width: 10),
                  Expanded(child: _FsrCell(
                    label: 'S4', sublabel: 'Kanan Belakang',
                    value: data.sensor4, pin: 33)),
                ],
              ),
              const SizedBox(height: 14),
              // Weight distribution visualizer
              _WeightDistribution(data: data),
            ],
          ),
        ),
      ],
    );
  }
}

class _FsrCell extends StatelessWidget {
  final String label;
  final String sublabel;
  final double value;
  final int pin;

  const _FsrCell({
    required this.label, required this.sublabel,
    required this.value, required this.pin,
  });

  Color get _color {
    if (value < 3) return AppTheme.textSecondary;   // Not active
    if (value < 8) return AppTheme.accentGreen;
    if (value < 15) return AppTheme.accentYellow;
    return AppTheme.accentRed;
  }

  double get _pct => (value / 20.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: value >= 3 ? 0.08 : 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(
                color: _color, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('PIN $pin', style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 9)),
            ],
          ),
          Text(sublabel, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(1)} N',
            style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _pct,
              minHeight: 4,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightDistribution extends StatelessWidget {
  final FatigueData data;
  const _WeightDistribution({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.sensor1 + data.sensor2 + data.sensor3 + data.sensor4;
    final leftPct = total > 0
        ? ((data.sensor1 + data.sensor3) / total * 100).toStringAsFixed(0)
        : '50';
    final rightPct = total > 0
        ? ((data.sensor2 + data.sensor4) / total * 100).toStringAsFixed(0)
        : '50';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCardAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.balance, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 8),
          const Text('Distribusi:', style: TextStyle(
            color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(width: 8),
          Text('Kiri $leftPct%', style: const TextStyle(
            color: AppTheme.accentBlue, fontWeight: FontWeight.bold, fontSize: 12)),
          const Spacer(),
          Text('Kanan $rightPct%', style: const TextStyle(
            color: AppTheme.accentOrange, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}