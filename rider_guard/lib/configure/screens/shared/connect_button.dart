import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConnectButton extends StatelessWidget {
  final bool isConnected;
  final String status;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.isConnected,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = status == 'connecting' || status == 'scanning';

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isConnected
              ? AppTheme.accentRed.withValues(alpha: 0.1)
              : AppTheme.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isConnected
                ? AppTheme.accentRed.withValues(alpha: 0.4)
                : AppTheme.accentBlue.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isConnected ? AppTheme.accentRed : AppTheme.accentBlue,
                ),
              )
            else
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                size: 14,
                color: isConnected ? AppTheme.accentRed : AppTheme.accentBlue,
              ),
            const SizedBox(width: 6),
            Text(
              isLoading ? (status == 'connecting' ? 'Menghubungkan...' : 'Scanning...')
                  : isConnected ? 'Putuskan' : 'Hubungkan',
              style: TextStyle(
                color: isConnected ? AppTheme.accentRed : AppTheme.accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}