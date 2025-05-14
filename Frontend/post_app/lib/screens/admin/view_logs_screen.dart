import 'package:flutter/material.dart';

class ViewLogsScreen extends StatelessWidget {
  const ViewLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Logs'),
      ),
      body: const Center(
        child: Text('View Logs Screen Content'),
      ),
    );
  }
}
