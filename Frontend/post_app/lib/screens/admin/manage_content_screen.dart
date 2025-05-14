import 'package:flutter/material.dart';

class ManageContentScreen extends StatelessWidget {
  const ManageContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Content'),
      ),
      body: const Center(
        child: Text('Manage Content Screen Content'),
      ),
    );
  }
}
