import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fatigue_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/fatigue_gauge.dart';
import 'widgets/fsr_sensor_grid.dart';
import 'widgets/fatigue_chart.dart';
import '../shared/connect_button.dart';
import '../blindspot/widgets/serial_log_panel.dart';
import 'fatigue_connect_sheet.dart';

class FatigueScreen extends StatelessWidget {
  const FatigueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FatigueProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.isConnected ? AppTheme.accentGreen : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Kelelahan Otot'),
              ],
            ),
            actions: [
              ConnectButton(
                isConnected: provider.isConnected,
                status: provider.connectionStatus,
                onTap: () {
                  if (provider.isConnected) {
                    provider.disconnect();
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppTheme.bgCard,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => const FatigueConnectSheet(),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: provider.isConnected
              ? _ConnectedView(provider: provider)
              : _DisconnectedView(),
        );
      },
    );
  }
}

class _ConnectedView extends StatefulWidget {
  final FatigueProvider provider;
  const _ConnectedView({required this.provider});

  @override
  State<_ConnectedView> createState() => _ConnectedViewState();
}

class _ConnectedViewState extends State<_ConnectedView>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accentOrange,
          labelColor: AppTheme.accentOrange,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'LIVE'),
            Tab(text: 'GRAFIK'),
            Tab(text: 'LOG'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _LiveTab(provider: widget.provider),
              FatigueChart(history: widget.provider.chartHistory),
              SerialLogPanel(logs: widget.provider.serialLog),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveTab extends StatelessWidget {
  final FatigueProvider provider;
  const _LiveTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.currentData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Session bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.bgCardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('Durasi', _formatDuration(data.durationSeconds)),
                _Stat('Jiggle Count', data.jiggleCount.toString()),
                _Stat('Status', data.fatigueLevel),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alert banner
          if (data.isAlertGelisah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppTheme.accentRed),
                  const SizedBox(width: 10),
                  const Text('ALERT: PENGENDARA GELISAH!',
                    style: TextStyle(color: AppTheme.accentRed,
                      fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),

          // Fatigue gauge
          FatigueGauge(
            durationSeconds: data.durationSeconds,
            level: data.fatigueLevel,
          ),
          const SizedBox(height: 16),

          // FSR sensor grid
          FsrSensorGrid(data: data),
          const SizedBox(height: 16),

          // Load bar
          _LoadCard(avgLoad: data.avgLoad),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          color: AppTheme.accentOrange, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _LoadCard extends StatelessWidget {
  final double avgLoad;
  const _LoadCard({required this.avgLoad});

  @override
  Widget build(BuildContext context) {
    final pct = (avgLoad / 20.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rata-rata Beban Kursi',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Text('${avgLoad.toStringAsFixed(1)} N',
                style: const TextStyle(color: AppTheme.accentOrange,
                  fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.7 ? AppTheme.accentRed
                    : pct > 0.4 ? AppTheme.accentYellow
                    : AppTheme.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisconnectedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.accessible_forward, size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text('Fatigue Monitor',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 22,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Hubungkan ke perangkat\n"FatigueMonitor_Adit" via BLE',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppTheme.bgCard,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => const FatigueConnectSheet(),
              );
            },
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('Scan & Hubungkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}