import 'package:flutter/material.dart';

class StampCollectionScreen extends StatelessWidget {
  const StampCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stamp Collection'),
      ),
      body: const Center(
        child: Text('Stamp Collection Screen Content'),
      ),
    );
  }
}
