import 'package:flutter/material.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Get in Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone, color: Theme.of(context).primaryColor),
              title: const Text('Phone'),
              subtitle: const Text('+94 11 232 8301'), // Sample number
              onTap: () {
                // TODO: Implement phone call action
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Theme.of(context).primaryColor),
              title: const Text('Email'),
              subtitle: const Text('info@slpost.lk'), // Sample email
              onTap: () {
                // TODO: Implement email action
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
              title: const Text('Address'),
              subtitle: const Text('Postal Headquarters,\nColombo 00100,\nSri Lanka'), // Sample address
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
            const Text('Monday - Friday: 8:30 AM - 4:15 PM'), // Sample hours
            const Text('Saturday: 8:30 AM - 1:00 PM'),
            const Text('Sunday: Closed'),
          ],
        ),
      ),
    );
  }
}
