import 'package:flutter/material.dart';

class LocationFAB extends StatelessWidget {
  final Function() onPressed;
  final bool isLoading;

  const LocationFAB({super.key, required this.onPressed, required this.isLoading});

  @override
  Widget build(context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )
          : const Icon(Icons.my_location),
    );
  }
}
