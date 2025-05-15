import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Placeholder for FAQ items
            _buildFAQItem('How do I track my parcel?', 'You can track your parcel by entering the tracking number on the Parcel Tracking screen.'),
            _buildFAQItem('How can I pay bills?', 'Navigate to the Bill Payments screen and select the bill type.'),
            _buildFAQItem('Where can I find postal holidays?', 'Check the Postal Holiday section on the customer dashboard.'),
            const SizedBox(height: 24.0),
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text('If you need further assistance, please contact us:'),
            const SizedBox(height: 8.0),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@slpost.lk'), // Sample email
              onTap: () {
                // TODO: Implement email action
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Support'),
              subtitle: const Text('+94 11 XXX XXXX'), // Sample number
              onTap: () {
                // TODO: Implement phone call action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0), // Corrected padding
          child: Text(answer),
        ),
      ],
    );
  }
}
