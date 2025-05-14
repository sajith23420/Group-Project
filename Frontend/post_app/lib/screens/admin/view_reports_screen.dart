import 'package:flutter/material.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Reports'),
      ),
      body: const Center(
        child: Text('View Reports Screen Content'),
      ),
    );
  }
}
