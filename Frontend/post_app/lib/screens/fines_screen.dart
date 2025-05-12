import 'package:flutter/material.dart';

class FinesScreen extends StatelessWidget {
  const FinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines'),
      ),
      body: const Center(
        child: Text('Fines Screen Content'),
      ),
    );
  }
}
