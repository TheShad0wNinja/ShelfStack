import 'package:flutter/material.dart';

/// A small utility widget that allows programmatic restart of the app
/// by rebuilding the widget tree with a new [Key]. Wrap your app with
/// `RestartWidget(child: MyApp())` in `main.dart` and call
/// `RestartWidget.restart(context)` to trigger a full rebuild.
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, super.key});

  static void restart(BuildContext context) {
    final _RestartWidgetState? state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
