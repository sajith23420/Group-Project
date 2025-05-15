import 'package:flutter/material.dart';
import 'package:post_app/screens/customer_dashboard_screen.dart';
// import 'package:post_app/screens/contact_details_screen.dart'; // Removed import
import 'package:post_app/screens/about_screen.dart';
import 'package:post_app/screens/my_profile_screen.dart';
import 'package:post_app/screens/notifications_screen.dart'; // Added import

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CustomerDashboardScreen(),
    AboutScreen(), // Moved About
    NotificationsScreen(), // Added Notifications
    MyProfileScreen(), // Moved Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline), // Moved About icon
            label: 'About', // Moved About label
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.notifications_outlined), // Added Notifications icon
            label: 'Notifications', // Added Notifications label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Moved Profile icon
            label: 'Profile', // Moved Profile label
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Theme.of(context).primaryColor, // Or your desired color
        unselectedItemColor: Colors.grey, // Or your desired color
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To ensure all labels are visible
      ),
    );
  }
}
