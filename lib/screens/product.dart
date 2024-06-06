import 'package:flutter/material.dart';

class PruductScreen extends StatelessWidget {
  static const String routeName = 'product';
  const PruductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments ?? 'No data';
    return Scaffold(
      body: Center(
        child: Text('$args', style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}
