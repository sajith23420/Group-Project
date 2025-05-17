import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Parcel Delivered',
        'message': 'Your parcel with tracking number ABC123 has been delivered.',
        'time': '2 hours ago',
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'New Promotion',
        'message': 'Check out our latest offers on postal services!',
        'time': 'Yesterday',
        'icon': Icons.local_offer_outlined,
      },
      {
        'title': 'Service Update',
        'message': 'Scheduled maintenance for online services on May 20th.',
        'time': '2 days ago',
        'icon': Icons.info_outline,
      },
       {
        'title': 'Parcel Out for Delivery',
        'message': 'Your parcel with tracking number XYZ789 is out for delivery today.',
        'time': 'Just now',
        'icon': Icons.local_shipping_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  notification['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['message'] as String),
                    const SizedBox(height: 4.0),
                    Text(
                      notification['time'] as String,
                      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Handle notification tap (e.g., navigate to relevant page)
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
