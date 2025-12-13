import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shelfstack/core/utils/files_helper.dart';

class QrCodeDialog extends StatefulWidget {
  final String containerId;
  final String containerName;

  const QrCodeDialog({
    super.key,
    required this.containerId,
    required this.containerName,
  });

  @override
  State<StatefulWidget> createState() => _QrCodeDialogState();
}

class _QrCodeDialogState extends State<QrCodeDialog> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadQRCode() async {
    setState(() => _isDownloading = true);

    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final success = await saveImageBytesToGallery(
        pngBytes,
        'qr_code_${widget.containerId}_${DateTime.now().millisecondsSinceEpoch}.png',
        albumName: 'ShelfStack',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to save QR code. Please check permissions.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error Saving QR code: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerId = widget.containerId;
    final containerName = widget.containerName;

    final qrCodeContent = 'shelfstack://container/$containerId';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Container QR Code',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RepaintBoundary(
              key: _qrKey,
              child: Column(
                children: [
                  Text(
                    containerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: QrImageView(
                      data: qrCodeContent,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ID: $containerId',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isDownloading ? null : _downloadQRCode,
                  icon: _isDownloading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(_isDownloading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
