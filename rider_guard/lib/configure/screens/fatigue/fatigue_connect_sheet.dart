import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../../providers/fatigue_provider.dart';
import '../../theme/app_theme.dart';

class FatigueConnectSheet extends StatefulWidget {
  const FatigueConnectSheet({super.key});

  @override
  State<FatigueConnectSheet> createState() => _FatigueConnectSheetState();
}

class _FatigueConnectSheetState extends State<FatigueConnectSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FatigueProvider>().startScan();
    });
  }

  @override
  void dispose() {
    context.read<FatigueProvider>().stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FatigueProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
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
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan Perangkat BLE',
                            style: TextStyle(color: AppTheme.textPrimary,
                              fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Mencari "FatigueMonitor_Adit"',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (provider.isScanning)
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accentOrange),
                      )
                    else
                      TextButton(
                        onPressed: provider.startScan,
                        child: const Text('Scan Ulang'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.scannedDevices.isEmpty
                      ? _ScanningEmpty(isScanning: provider.isScanning)
                      : ListView.separated(
                          controller: controller,
                          itemCount: provider.scannedDevices.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final device = provider.scannedDevices[i];
                            return _BleTile(
                              device: device,
                              onTap: () async {
                                Navigator.pop(context);
                                await provider.connectToDevice(device);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BleTile extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onTap;
  const _BleTile({required this.device, required this.onTap});

  bool get _isFatigue => device.name.contains('Fatigue') || device.name.contains('Adit');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isFatigue ? AppTheme.accentOrange.withValues(alpha: 0.08) : AppTheme.bgCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFatigue
                ? AppTheme.accentOrange.withValues(alpha: 0.4)
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.bluetooth,
              color: _isFatigue ? AppTheme.accentOrange : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name.isEmpty ? 'Unknown BLE' : device.name,
                    style: TextStyle(
                      color: _isFatigue ? AppTheme.accentOrange : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
                  Text(device.id,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            // RSSI indicator
            Column(
              children: [
                Icon(Icons.signal_cellular_alt,
                  size: 14, color: _rssiColor(device.rssi)),
                Text('${device.rssi} dBm',
                  style: TextStyle(color: _rssiColor(device.rssi), fontSize: 9)),
              ],
            ),
            if (_isFatigue) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('COCOK', style: TextStyle(
                  color: AppTheme.accentOrange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _rssiColor(int rssi) {
    if (rssi > -60) return AppTheme.accentGreen;
    if (rssi > -80) return AppTheme.accentYellow;
    return AppTheme.accentRed;
  }
}

class _ScanningEmpty extends StatelessWidget {
  final bool isScanning;
  const _ScanningEmpty({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isScanning) ...[
            const CircularProgressIndicator(color: AppTheme.accentOrange),
            const SizedBox(height: 16),
            const Text('Sedang mencari perangkat...',
              style: TextStyle(color: AppTheme.textSecondary)),
          ] else ...[
            const Icon(Icons.bluetooth_disabled,
              color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 12),
            const Text('Tidak ada perangkat BLE ditemukan',
              style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            const Text('Pastikan ESP32 "FatigueMonitor_Adit"\nsudah menyala dan BLE aktif',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}