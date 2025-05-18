import 'package:flutter/material.dart';

// Import service screens
import 'package:post_app/screens/parcel_tracking_screen.dart';
import 'package:post_app/screens/money_order_screen.dart';
import 'package:post_app/screens/bill_payments_screen.dart';
import 'package:post_app/screens/postal_holiday_screen.dart';
import 'package:post_app/screens/search_post_office_screen.dart';
import 'package:post_app/screens/fines_screen.dart';
import 'package:post_app/screens/login_screen.dart'; // Import LoginScreen
import 'package:post_app/screens/feedbacks_page.dart'; // Import FeedbacksPage
// For logout

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _greeting = '';
  final PageController _newsPageController = PageController();
  int _currentNewsPage = 0;
  final int _newsImageCount = 3;

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour == 12) {
      _greeting = 'Good Afternoon';
    } else if (hour < 18) {
      _greeting = 'Good Evening';
    } else {
      _greeting = 'Good Night';
    }
  }

  @override
  void dispose() {
    _newsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [ // ignore: unused_local_variable
      {'title': 'Parcel Tracking', 'icon': Icons.local_shipping},
      {'title': 'Money Order', 'icon': Icons.attach_money},
      {'title': 'Bill Payments', 'icon': Icons.payment},
      {'title': 'Postal Holiday', 'icon': Icons.calendar_today},
      {'title': 'Search Nearby\nPost Office', 'icon': Icons.location_on},
      {'title': 'Fines', 'icon': Icons.gavel},
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset("assets/post_icon.png", height: 40),
            const SizedBox(width: 10),
            const Text("Dashboard"),
          ],
        ),
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
            UserAccountsDrawerHeader(
              accountName: const Text("User Name"),
              accountEmail: const Text("user.email@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ? Colors.blue : Colors.white,
                child: const Text("U", style: TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Add Payment Card'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
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
          children: <Widget>[
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$_greeting, User Name!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  context,
                  services[index]['title'] as String,
                  services[index]['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Latest News',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _newsPageController,
                itemCount: _newsImageCount,
                onPageChanged: (int page) {
                  setState(() {
                    _currentNewsPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.7),
                      ),
                      child: Center(
                        child: Text(
                          'News Image ${index + 1}',
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_newsImageCount, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentNewsPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.feedback),
                label: const Text('Give Feedback'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbacksPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon) {
    Widget? screen;
    String normalizedTitle = title.replaceAll('\n', ' ');

    switch (normalizedTitle) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
