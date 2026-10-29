import 'package:flutter/material.dart';
import '../../../models/blindspot_model.dart';
import '../../../theme/app_theme.dart';

class BlindspotStatusCards extends StatelessWidget {
  final BlindspotData? data;
  const BlindspotStatusCards({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Left/Right hazard indicator (big)
        Row(
          children: [
            Expanded(child: _HazardCard(
              side: 'KIRI',
              level: data?.hazardLeft ?? 0,
              icon: Icons.arrow_back,
            )),
            const SizedBox(width: 12),
            Expanded(child: _HazardCard(
              side: 'KANAN',
              level: data?.hazardRight ?? 0,
              icon: Icons.arrow_forward,
            )),
          ],
        ),
        const SizedBox(height: 12),
        // Sensor data row
        Row(
          children: [
            Expanded(child: _MetricCard(
              label: 'Jarak (LD2450)',
              value: data != null ? '${data!.distance.toStringAsFixed(2)} m' : '-- m',
              icon: Icons.straighten,
              color: AppTheme.accentBlue,
            )),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(
              label: 'Posisi X',
              value: data != null ? '${data!.posX.toStringAsFixed(0)} mm' : '-- mm',
              icon: Icons.swap_horiz,
              color: AppTheme.accentOrange,
              subtitle: data != null
                  ? (data!.posX < -400 ? '← Kiri' : data!.posX > 400 ? 'Kanan →' : 'Tengah')
                  : null,
            )),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(
              label: 'Kecepatan',
              value: data != null ? '${data!.speed.toStringAsFixed(2)} m' : '-- m',
              icon: Icons.speed,
              color: AppTheme.accentYellow,
              subtitle: 'jarak LD2451',
            )),
          ],
        ),
      ],
    );
  }
}

class _HazardCard extends StatelessWidget {
  final String side;
  final int level;
  final IconData icon;
  const _HazardCard({required this.side, required this.level, required this.icon});

  Color get _bgColor {
    switch (level) {
      case 2: return AppTheme.accentRed.withValues(alpha: 0.12);
      case 1: return AppTheme.accentYellow.withValues(alpha: 0.12);
      default: return AppTheme.accentGreen.withValues(alpha: 0.08);
    }
  }

  Color get _borderColor {
    switch (level) {
      case 2: return AppTheme.accentRed.withValues(alpha: 0.5);
      case 1: return AppTheme.accentYellow.withValues(alpha: 0.5);
      default: return AppTheme.accentGreen.withValues(alpha: 0.3);
    }
  }

  Color get _textColor {
    switch (level) {
      case 2: return AppTheme.accentRed;
      case 1: return AppTheme.accentYellow;
      default: return AppTheme.accentGreen;
    }
  }

  String get _label => BlindspotData.hazardLabel(level);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _textColor, size: 18),
              const SizedBox(width: 6),
              Text(side, style: TextStyle(
                color: _textColor, fontWeight: FontWeight.bold, fontSize: 13,
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text(_label, style: TextStyle(
            color: _textColor, fontWeight: FontWeight.w800, fontSize: 20,
            letterSpacing: 1,
          )),
          const SizedBox(height: 4),
          // Level indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= level ? _textColor : _textColor.withValues(alpha: 0.2),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 15,
          )),
          Text(label, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 10,
          )),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(
              color: color.withValues(alpha: 0.7), fontSize: 10,
            )),
        ],
      ),
    );
  }
}