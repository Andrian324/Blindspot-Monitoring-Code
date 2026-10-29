import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/fatigue_model.dart';
import '../../../theme/app_theme.dart';

class FatigueChart extends StatelessWidget {
  final List<FatigueData> history;
  const FatigueChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SensorChart(
            title: 'Beban FSR S1 & S2 (Newton)',
            spots1: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.sensor1)).toList(),
            spots2: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.sensor2)).toList(),
            label1: 'S1 Kiri Depan',
            label2: 'S2 Kanan Depan',
            color1: AppTheme.accentBlue,
            color2: AppTheme.accentOrange,
          ),
          const SizedBox(height: 16),
          _SensorChart(
            title: 'Beban FSR S3 & S4 (Newton)',
            spots1: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.sensor3)).toList(),
            spots2: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.sensor4)).toList(),
            label1: 'S3 Kiri Belakang',
            label2: 'S4 Kanan Belakang',
            color1: AppTheme.accentGreen,
            color2: AppTheme.accentYellow,
          ),
          const SizedBox(height: 16),
          _DurationChart(history: history),
        ],
      ),
    );
  }
}

class _SensorChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots1;
  final List<FlSpot> spots2;
  final String label1, label2;
  final Color color1, color2;

  const _SensorChart({
    required this.title,
    required this.spots1, required this.spots2,
    required this.label1, required this.label2,
    required this.color1, required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _LegendDot(color: color1, label: label1),
              const SizedBox(width: 16),
              _LegendDot(color: color2, label: label2),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: spots1.isEmpty
                ? const Center(child: Text('Belum ada data',
                    style: TextStyle(color: AppTheme.textSecondary)))
                : LineChart(LineChartData(
                    minY: 0, maxY: 22,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: AppTheme.borderColor, strokeWidth: 1),
                      getDrawingVerticalLine: (_) =>
                          FlLine(color: AppTheme.borderColor, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                            style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 9)),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      _bar(spots1, color1),
                      _bar(spots2, color2),
                    ],
                  )),
          ),
        ],
      ),
    );
  }

  LineChartBarData _bar(List<FlSpot> s, Color c) => LineChartBarData(
    spots: s, color: c, barWidth: 2, isCurved: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.06)),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }
}

class _DurationChart extends StatelessWidget {
  final List<FatigueData> history;
  const _DurationChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.durationSeconds / 60.0))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DURASI BERKENDARA (menit)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: spots.isEmpty
                ? const Center(child: Text('Belum ada data',
                    style: TextStyle(color: AppTheme.textSecondary)))
                : LineChart(LineChartData(
                    minY: 0, maxY: 35,
                    gridData: FlGridData(show: true,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: AppTheme.borderColor, strokeWidth: 1),
                      getDrawingVerticalLine: (_) =>
                          FlLine(color: AppTheme.borderColor, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 28,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}m',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                      )),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        color: AppTheme.accentOrange,
                        barWidth: 2, isCurved: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true, color: AppTheme.accentOrange.withValues(alpha: 0.08)),
                      ),
                    ],
                  )),
          ),
        ],
      ),
    );
  }
}