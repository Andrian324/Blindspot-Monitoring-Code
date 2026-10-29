import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../providers/blindspot_provider.dart';
import '../../theme/app_theme.dart';

class BlindspotConnectSheet extends StatefulWidget {
  const BlindspotConnectSheet({super.key});

  @override
  State<BlindspotConnectSheet> createState() => _BlindspotConnectSheetState();
}

class _BlindspotConnectSheetState extends State<BlindspotConnectSheet> {
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    final provider = context.read<BlindspotProvider>();
    provider.startScan();
    setState(() => _scanning = true);
  }

  void _stopScan() {
    final provider = context.read<BlindspotProvider>();
    provider.stopScan();
    setState(() => _scanning = false);
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cari Perangkat BLE',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                if (_scanning)
                  GestureDetector(
                    onTap: _stopScan,
                    child: const Text('Hentikan', style: TextStyle(
                      color: AppTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Pastikan perangkat Blindspot dalam jangkauan dan dinyalakan',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<BlindspotProvider>(
                builder: (_, provider, _) {
                  final devices = provider.availableDevices;
                  return devices.isEmpty
                      ? _EmptyState(onRetry: _startScan)
                      : ListView.separated(
                          controller: controller,
                          itemCount: devices.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final messenger = ScaffoldMessenger.of(context);
                            return _DeviceTile(
                              device: devices[i],
                              onTap: () async {
                                _stopScan();
                                Navigator.pop(context);
                                try {
                                  await provider.connectToDevice(devices[i]);
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(
                                    content: Text('Tidak dapat terhubung: ${e.toString()}'),
                                    duration: const Duration(seconds: 4),
                                  ));
                                }
                              },
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onTap;
  const _DeviceTile({required this.device, required this.onTap});

  bool get _isRadar => device.name.contains('Radar') || device.name.contains('Blindspot');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isRadar ? AppTheme.accentBlue.withValues(alpha: 0.08) : AppTheme.bgCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isRadar ? AppTheme.accentBlue.withValues(alpha: 0.4) : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.bluetooth,
              color: _isRadar ? AppTheme.accentBlue : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name,
                    style: TextStyle(
                      color: _isRadar ? AppTheme.accentBlue : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                  Text(device.id,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            if (_isRadar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('COCOK', style: TextStyle(
                  color: AppTheme.accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 12),
          const Text('Tidak ada perangkat ditemukan',
            style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Pastikan perangkat Blindspot dinyalakan\ndan dalam jangkauan',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}