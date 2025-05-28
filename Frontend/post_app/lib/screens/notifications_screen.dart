import 'package:flutter/material.dart';
//import 'package:path/path.dart';
//import 'package:post_app/screens/customer_dashboard_screen.dart';
//import 'package:post_app/screens/main_app_shell.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.pinkAccent,
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              SizedBox(
                width: 56,
                height: 56,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 32),
                  tooltip: 'Clear All Notifications',
                  onPressed: () {
                    // Clear notifications logic
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Render each notification as a Card
              ...notifications.map((notification) => Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 2.0),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Material(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
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
                              color: Colors.pinkAccent,
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
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  label: const Text(
                    "Mark All as Read",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    side: const BorderSide(color: Colors.pinkAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
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
