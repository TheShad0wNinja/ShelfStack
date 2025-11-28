import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final VoidCallback onCreateContainer;
  final VoidCallback onCreateItem;

  const ExpandableFab({
    super.key,
    required this.onCreateContainer,
    required this.onCreateItem,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _buildFabOption(
        icon: Icons.add_box_outlined,
        label: 'Create Item',
        onPressed: widget.onCreateItem,
        animation: _expandAnimation,
      ),
      _buildFabOption(
        icon: Icons.inventory_2_outlined,
        label: 'Create Container',
        onPressed: widget.onCreateContainer,
        animation: _expandAnimation,
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...menuItems.map((widget) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: widget,
          );
        }),

        FloatingActionButton(
          onPressed: _toggle,
          tooltip: _isOpen ? 'Close menu' : 'Open menu',
          shape: _isOpen
              ? const CircleBorder()
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: () {
              _toggle();
              onPressed();
            },
            icon: Icon(icon),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}
