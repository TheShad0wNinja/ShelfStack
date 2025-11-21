import 'package:flutter/material.dart';

class RoundedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final double elevation;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RoundedAppBar({
    super.key,
    this.height = 80,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.elevation = 1,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      // avoid M3 tint
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(borderRadius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
