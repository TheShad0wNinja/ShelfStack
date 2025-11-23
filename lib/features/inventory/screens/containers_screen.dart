import 'package:flutter/material.dart';
import 'package:shelfstack/core/widgets/rounded_appbar.dart';

class ContainersScreen extends StatelessWidget {
  const ContainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const RoundedAppBar(child: Text("Containers")));
  }
}
