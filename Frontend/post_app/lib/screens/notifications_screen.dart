import 'package:flutter/material.dart';
//import 'package:path/path.dart';
//import 'package:post_app/screens/customer_dashboard_screen.dart';
import 'package:post_app/screens/main_app_shell.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Parcel Delivered',
        'message':
            'Your parcel with tracking number ABC123 has been delivered.',
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
        'message':
            'Your parcel with tracking number XYZ789 is out for delivery today.',
        'time': 'Just now',
        'icon': Icons.local_shipping_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (Context) {
                return MainAppShell();
              }));
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        actions: [
          SizedBox(
            width: 56, // Adjust width
            height: 56, // Adjust height
            child: IconButton(
              icon: Icon(Icons.delete,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 32), // Adjust icon size
              tooltip: 'Clear All Notifications',
              onPressed: () {
                // Clear notifications logic
              },
            ),
          )
        ],
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Render each notification as a Card
              ...notifications.map((notification) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 2.0,
                    child: Material(
                      child: InkWell(
                        splashColor: const Color.fromARGB(174, 255, 64, 128),
                        onTap: () {
                          //can add on tap function
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
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
                                style: const TextStyle(
                                    fontSize: 12.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                height: 20,
              ),

              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.done_all,
                    color: const Color.fromARGB(255, 230, 211, 211),
                  ),
                  label: Text(
                    "Mark All as Read",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                  onPressed: () {
                    // Clear notifications logic
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
