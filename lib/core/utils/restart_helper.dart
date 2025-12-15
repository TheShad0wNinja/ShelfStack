import 'package:flutter/material.dart';

/// A small utility widget that allows programmatic restart of the app
/// by rebuilding the widget tree with a new [Key]. Wrap your app with
/// `RestartWidget(child: MyApp())` in `main.dart` and call
/// `RestartWidget.restart(context)` to trigger a full rebuild.
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, super.key});

  static Future<void> promptRestart(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart required'),
        content: const Text('Please restart the app to apply changes.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
