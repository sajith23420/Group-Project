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
            _buildFAQItem('How do I track my parcel?', 'You can track your parcel by entering the tracking number on the Parcel Tracking screen.'),
            _buildFAQItem('How can I pay bills?', 'Navigate to the Bill Payments screen and select the bill type.'),
            _buildFAQItem('Where can I find postal holidays?', 'Check the Postal Holiday section on the customer dashboard.'),
            const SizedBox(height: 24.0),
            const Text(
              'Contact Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Get in Touch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.phone, color: Theme.of(context).primaryColor),
              title: const Text('Phone'),
              subtitle: const Text('+94 11 232 8301'),
              onTap: () {
                // TODO: Implement phone call action
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Theme.of(context).primaryColor),
              title: const Text('Email'),
              subtitle: const Text('info@slpost.lk'),
              onTap: () {
                // TODO: Implement email action
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
              title: const Text('Address'),
              subtitle: const Text('Postal Headquarters,\nColombo 00100,\nSri Lanka'),
              onTap: () {
                // TODO: Implement map action
              },
            ),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Business Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Monday - Friday: 8:30 AM - 4:15 PM'),
            const Text('Saturday: 8:30 AM - 1:00 PM'),
            const Text('Sunday: Closed'),
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
              subtitle: const Text('support@slpost.lk'),
              onTap: () {
                // TODO: Implement email action
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Support'),
              subtitle: const Text('+94 11 XXX XXXX'),
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
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
