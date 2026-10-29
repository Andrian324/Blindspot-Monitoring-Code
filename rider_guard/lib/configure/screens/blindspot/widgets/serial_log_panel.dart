import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class SerialLogPanel extends StatefulWidget {
  final List<String> logs;
  const SerialLogPanel({super.key, required this.logs});

  @override
  State<SerialLogPanel> createState() => _SerialLogPanelState();
}

class _SerialLogPanelState extends State<SerialLogPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void didUpdateWidget(SerialLogPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCardAlt,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, color: AppTheme.accentGreen, size: 14),
                const SizedBox(width: 8),
                const Text('Serial Monitor',
                  style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, letterSpacing: 1)),
                const Spacer(),
                Text('${widget.logs.length} baris',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _autoScroll = !_autoScroll),
                  child: Icon(
                    _autoScroll ? Icons.lock : Icons.lock_open,
                    size: 14,
                    color: _autoScroll ? AppTheme.accentGreen : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.logs.join('\n')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Log disalin ke clipboard')),
                    );
                  },
                  child: const Icon(Icons.copy, size: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          // Log content
          Expanded(
            child: widget.logs.isEmpty
                ? const Center(
                    child: Text('Menunggu data...',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.logs.length,
                    itemBuilder: (context, index) {
                      final log = widget.logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: _logColor(log),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _logColor(String log) {
    if (log.contains('BAHAYA') || log.contains('ALERT') || log.contains('GELISAH')) {
      return AppTheme.accentRed;
    }
    if (log.contains('WASPADA') || log.contains('JIGGLE')) return AppTheme.accentYellow;
    if (log.contains('AMAN') || log.contains('Connected')) return AppTheme.accentGreen;
    if (log.startsWith('[') && log.contains(']')) return AppTheme.accentBlue.withValues(alpha: 0.8);
    return const Color(0xFF8BD5CA);
  }
}