import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/blindspot_model.dart';
import '../../../theme/app_theme.dart';

class BlindspotChart extends StatelessWidget {
  final List<BlindspotData> history;
  const BlindspotChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ChartCard(
            title: 'Jarak Terdeteksi (meter)',
            spots: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.distance))
                .toList(),
            color: AppTheme.accentBlue,
            maxY: 5,
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Posisi X (mm)',
            spots: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.posX / 100)) // cm
                .toList(),
            color: AppTheme.accentOrange,
            maxY: 10, minY: -10,
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Level Hazard Kiri & Kanan',
            spots: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.hazardLeft.toDouble()))
                .toList(),
            extraSpots: history.asMap().entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.hazardRight.toDouble()))
                .toList(),
            color: AppTheme.accentRed,
            extraColor: AppTheme.accentYellow,
            maxY: 3,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final List<FlSpot>? extraSpots;
  final Color color;
  final Color? extraColor;
  final double maxY;
  final double minY;

  const _ChartCard({
    required this.title,
    required this.spots,
    this.extraSpots,
    required this.color,
    this.extraColor,
    required this.maxY,
    this.minY = 0,
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
            color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1,
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: spots.isEmpty
                ? const Center(child: Text('Belum ada data',
                    style: TextStyle(color: AppTheme.textSecondary)))
                : LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.borderColor, strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => FlLine(
                          color: AppTheme.borderColor, strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, reservedSize: 30,
                            getTitlesWidget: (v, _) => Text(
                              v.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 9),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        _lineBar(spots, color),
                        if (extraSpots != null && extraColor != null)
                          _lineBar(extraSpots!, extraColor!),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(List<FlSpot> s, Color c) => LineChartBarData(
    spots: s,
    color: c,
    barWidth: 2,
    isCurved: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      color: c.withValues(alpha: 0.08),
    ),
  );
}