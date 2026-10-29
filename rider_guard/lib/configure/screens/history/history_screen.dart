import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/blindspot_model.dart';
import '../../models/fatigue_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penggunaan'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accentBlue,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'BLINDSPOT'),
            Tab(text: 'KELELAHAN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _BlindspotHistory(),
          _FatigueHistory(),
        ],
      ),
    );
  }
}

// ===== BLINDSPOT HISTORY =====
class _BlindspotHistory extends StatelessWidget {
  const _BlindspotHistory();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BlindspotSession>>(
      stream: FirebaseService.blindspotSessionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}',
            style: const TextStyle(color: AppTheme.accentRed)));
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return const _EmptyHistory(label: 'Belum ada riwayat blindspot');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BlindspotSessionCard(session: sessions[i]),
        );
      },
    );
  }
}

class _BlindspotSessionCard extends StatelessWidget {
  final BlindspotSession session;
  const _BlindspotSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy  HH:mm');
    final dur = session.endTime?.difference(session.startTime);

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
            children: [
              const Icon(Icons.radar, color: AppTheme.accentBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(session.deviceName,
                  style: const TextStyle(color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600)),
              ),
              _StatusBadge(session.endTime != null ? 'Selesai' : 'Aktif',
                session.endTime != null ? AppTheme.accentGreen : AppTheme.accentYellow),
            ],
          ),
          const SizedBox(height: 10),
          Text(fmt.format(session.startTime),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(Icons.warning_rounded, '${session.totalAlerts} Alert',
                session.totalAlerts > 0 ? AppTheme.accentRed : AppTheme.textSecondary),
              const SizedBox(width: 12),
              _InfoChip(Icons.straighten, '${session.maxDistance.toStringAsFixed(1)}m max',
                AppTheme.accentBlue),
              if (dur != null) ...[
                const SizedBox(width: 12),
                _InfoChip(Icons.timer, _formatDur(dur), AppTheme.textSecondary),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${session.id.substring(0, 12)}...',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10,
              fontFamily: 'monospace')),
        ],
      ),
    );
  }

  String _formatDur(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

// ===== FATIGUE HISTORY =====
class _FatigueHistory extends StatelessWidget {
  const _FatigueHistory();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FatigueSession>>(
      stream: FirebaseService.fatigueSessionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}',
            style: const TextStyle(color: AppTheme.accentRed)));
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return const _EmptyHistory(label: 'Belum ada riwayat kelelahan');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _FatigueSessionCard(session: sessions[i]),
        );
      },
    );
  }
}

class _FatigueSessionCard extends StatelessWidget {
  final FatigueSession session;
  const _FatigueSessionCard({required this.session});

  Color _levelColor(String level) {
    switch (level) {
      case 'KRITIS': return AppTheme.accentRed;
      case 'LELAH': return AppTheme.accentOrange;
      case 'WASPADA': return AppTheme.accentYellow;
      default: return AppTheme.accentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy  HH:mm');
    final maxDurMin = session.maxDuration ~/ 60;
    final maxDurSec = session.maxDuration % 60;

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
            children: [
              const Icon(Icons.accessible_forward,
                color: AppTheme.accentOrange, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('FatigueMonitor_Adit',
                  style: TextStyle(color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600)),
              ),
              _StatusBadge(session.endTime != null ? 'Selesai' : 'Aktif',
                session.endTime != null ? AppTheme.accentGreen : AppTheme.accentYellow),
            ],
          ),
          const SizedBox(height: 10),
          Text(fmt.format(session.startTime),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(Icons.timer, '${maxDurMin}m ${maxDurSec}s',
                AppTheme.accentOrange),
              const SizedBox(width: 12),
              _InfoChip(Icons.vibration, '${session.totalJiggles} Jiggle',
                session.totalJiggles > 5 ? AppTheme.accentRed : AppTheme.textSecondary),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _levelColor(session.maxFatigueLevel).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _levelColor(session.maxFatigueLevel).withValues(alpha: 0.4)),
                ),
                child: Text(session.maxFatigueLevel,
                  style: TextStyle(
                    color: _levelColor(session.maxFatigueLevel),
                    fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${session.id.substring(0, 12)}...',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10,
              fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ===== SHARED WIDGETS =====
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final String label;
  const _EmptyHistory({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Data akan muncul setelah sesi pertama selesai',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}