import 'package:flutter/material.dart';
import 'package:post_app/screens/login_screen.dart';
import 'package:post_app/screens/parcel_tracking_screen.dart';
import 'package:post_app/screens/money_order_screen.dart';
import 'package:post_app/screens/bill_payments_screen.dart';
import 'package:post_app/screens/postal_holiday_screen.dart';
import 'package:post_app/screens/search_post_office_screen.dart';
import 'package:post_app/screens/fines_screen.dart';
import 'package:post_app/screens/stamp_collection_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'title': 'Parcel Tracking', 'icon': Icons.local_shipping},
      {'title': 'Money Order', 'icon': Icons.attach_money},
      {'title': 'Bill Payments', 'icon': Icons.payment},
      {'title': 'Postal Holiday', 'icon': Icons.calendar_today},
      {'title': 'Search Nearby\nPost Office', 'icon': Icons.location_on},
      {'title': 'Fines', 'icon': Icons.gavel},
      {'title': 'Stamp Collection', 'icon': Icons.collections_bookmark},
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('SL Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user.email@example.com"),
              currentAccountPicture: CircleAvatar(
                child: Text("U"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting, User!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  context,
                  services[index]['title'],
                  services[index]['icon'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    Widget? screen;

    switch (title.replaceAll('\n', ' ')) {
      case 'Parcel Tracking':
        screen = const ParcelTrackingScreen();
        break;
      case 'Money Order':
        screen = const MoneyOrderScreen();
        break;
      case 'Bill Payments':
        screen = const BillPaymentsScreen();
        break;
      case 'Postal Holiday':
        screen = const PostalHolidayScreen();
        break;
      case 'Search Nearby Post Office':
        screen = const SearchPostOfficeScreen();
        break;
      case 'Fines':
        screen = const FinesScreen();
        break;
      case 'Stamp Collection':
        screen = const StampCollectionScreen();
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen!),
            );
          }
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
