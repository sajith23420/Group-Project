import 'package:flutter/material.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SL Post'),
        automaticallyImplyLeading: false, // To remove back button if it's a main dashboard
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter Tracking Number',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  // Handle track button press
                },
                child: const Text('Track'),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              _buildServiceTile(context, 'Money Order', Icons.attach_money),
              _buildServiceTile(context, 'Bill Payments', Icons.payment),
              _buildServiceTile(context, 'Parcel Tracking', Icons.local_shipping),
              _buildServiceTile(context, 'Postal Holiday', Icons.calendar_today),
              _buildServiceTile(context, 'Search Nearby Post Office', Icons.location_on),
              _buildServiceTile(context, 'Fines', Icons.gavel),
              _buildServiceTile(context, 'Stamp Collection', Icons.collections_bookmark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: () {
          // Handle service tile tap
        },
      ),
    );
  }
}
