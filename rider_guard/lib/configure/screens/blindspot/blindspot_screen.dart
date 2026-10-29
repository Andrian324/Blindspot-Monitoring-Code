import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/blindspot_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/radar_visualizer.dart';
import 'widgets/blindspot_status_cards.dart';
import 'widgets/blindspot_chart.dart';
import 'widgets/serial_log_panel.dart';
import '../shared/connect_button.dart';
import 'blindspot_connect_sheet.dart';

class BlindspotScreen extends StatelessWidget {
  const BlindspotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BlindspotProvider>(
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
                const Text('Blindspot Monitor'),
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
                      builder: (_) => const BlindspotConnectSheet(),
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
  final BlindspotProvider provider;
  const _ConnectedView({required this.provider});

  @override
  State<_ConnectedView> createState() => _ConnectedViewState();
}

class _ConnectedViewState extends State<_ConnectedView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentBlue,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'LIVE'),
            Tab(text: 'GRAFIK'),
            Tab(text: 'LOG'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _LiveTab(provider: widget.provider),
              BlindspotChart(history: widget.provider.chartHistory),
              SerialLogPanel(logs: widget.provider.serialLog),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveTab extends StatelessWidget {
  final BlindspotProvider provider;
  const _LiveTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Session info bar
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
                _SessionStat('Sesi ID', provider.sessionId?.substring(0, 8) ?? '-'),
                _SessionStat('Total Alert', provider.totalAlerts.toString()),
                _SessionStat('Perangkat', provider.connectedDevice?.name ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Radar Visualizer
          RadarVisualizer(data: provider.currentData),
          const SizedBox(height: 16),
          // Status Cards
          BlindspotStatusCards(data: provider.currentData),
        ],
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final String label;
  final String value;
  const _SessionStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          color: AppTheme.accentBlue, fontWeight: FontWeight.bold, fontSize: 15,
        )),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
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
          Icon(Icons.radar, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          const Text(
            'Blindspot Monitor',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hubungkan ke perangkat Blindspot\nvia Bluetooth Low Energy',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppTheme.bgCard,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const BlindspotConnectSheet(),
              );
            },
            icon: const Icon(Icons.bluetooth),
            label: const Text('Hubungkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
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