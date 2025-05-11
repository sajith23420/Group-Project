import 'package:flutter/material.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: const Center(
        child: Text('Contact Details Screen Content'),
      ),
    );
  }
}
