import 'package:flutter/material.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[100], // Light color theme
        title: const Text('System Settings',
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: const Center(
        child: Text('System Settings Screen Content'),
      ),
    );
  }
}
