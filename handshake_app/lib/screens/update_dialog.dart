import 'package:flutter/material.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final success = await UpdateService.downloadAndInstall(
      widget.updateInfo,
      onProgress: (progress) {
        setState(() => _downloadProgress = progress);
      },
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Letöltési hiba történt'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1D2137),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Cím
            const Text(
              '🎉 Új verzió elérhető!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Verzió + méret
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v${widget.updateInfo.version} • ${widget.updateInfo.sizeFormatted}',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Leírás
            if (widget.updateInfo.description.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateInfo.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Letöltési progress vagy gombok
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'Letöltés... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ne zárd be az appot!',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Később',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _startUpdate,
                      icon: const Icon(Icons.download),
                      label: const Text('Frissítés most'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
