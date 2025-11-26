import 'package:flutter/material.dart';

class ThemedTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const ThemedTextField({
    super.key,
    this.hintText = '',
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        hintText: 'Search containers...',
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 16,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller?.clear(),
          color: Colors.grey,
        ),
      ),
    );
  }
}