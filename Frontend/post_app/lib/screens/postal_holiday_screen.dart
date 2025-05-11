import 'package:flutter/material.dart';

class PostalHolidayScreen extends StatelessWidget {
  const PostalHolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postal Holiday'),
      ),
      body: const Center(
        child: Text('Postal Holiday Screen Content'),
      ),
    );
  }
}
