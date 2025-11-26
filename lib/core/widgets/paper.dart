import 'package:flutter/material.dart';

class Paper extends StatelessWidget {
  final Widget child;
  const Paper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: child,
    );
  }

}