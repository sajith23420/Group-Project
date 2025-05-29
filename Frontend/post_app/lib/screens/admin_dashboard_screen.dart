import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:post_app/providers/user_provider.dart'; // Import UserProvider
import 'package:post_app/models/user_model.dart'; // Import UserModel
import 'package:post_app/screens/login_screen.dart'; // Import LoginScreen
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:fl_chart/fl_chart.dart';

// Import admin action screens
import 'package:post_app/screens/admin/manage_users_screen.dart';
import 'package:post_app/screens/admin/manage_services_screen.dart';
// import 'package:post_app/screens/admin/system_settings_screen.dart';
import 'package:post_app/screens/admin/admin_news_carousel_screen.dart';
import 'package:post_app/screens/admin/admin_parcel_tracking_control_screen.dart'; // Import the new screen

class AdminDashboardScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Track the current theme color
  Color _currentThemeColor = Colors.indigo;
  Color _currentHeaderBg = Colors.indigo.shade50;
  Color _currentHeaderIcon = Colors.indigo;

  // Admin actions for dashboard
  final List<Map<String, dynamic>> adminActions = [
    {
      'title': 'Manage Users',
      'icon': Icons.people_outline,
      'color': Colors.blue
    },
    {
      'title': 'Manage Services',
      'icon': Icons.settings_applications_outlined,
      'color': Colors.orange
    },
    {
      'title': 'Manage News Carousel',
      'icon': Icons.newspaper,
      'color': Colors.pinkAccent
    },
    {
      'title': 'Parcel Tracking Control',
      'icon': Icons.local_shipping_outlined,
      'color': Colors.amber
    },
  ];

  // Helper to update theme color based on action
  void _setThemeForAction(String title) {
    switch (title) {
      case 'Manage Users':
        _currentThemeColor = Colors.indigo;
        _currentHeaderBg = Colors.indigo.shade100;
        _currentHeaderIcon = Colors.indigo;
        break;
      case 'Manage Services':
        _currentThemeColor = Colors.deepPurple;
        _currentHeaderBg = Colors.deepPurple.shade50;
        _currentHeaderIcon = Colors.deepPurple;
        break;
      case 'System Settings':
        _currentThemeColor = Colors.teal;
        _currentHeaderBg = Colors.teal.shade50;
        _currentHeaderIcon = Colors.teal;
        break;
      case 'Manage News Carousel':
        _currentThemeColor = Colors.pink;
        _currentHeaderBg = Colors.pink.shade50;
        _currentHeaderIcon = Colors.pink;
        break;
      case 'Parcel Tracking Control':
        _currentThemeColor = Colors.amber[800]!;
        _currentHeaderBg = Colors.amber.shade50;
        _currentHeaderIcon = Colors.amber[800]!;
        break;
      default:
        _currentThemeColor = Colors.indigo;
        _currentHeaderBg = Colors.indigo.shade50;
        _currentHeaderIcon = Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? currentUser = userProvider.user;

    // Sample data for the chart (replace with real data as needed)
    final List<BarChartGroupData> barGroups = [
      BarChartGroupData(
          x: 0, barRods: [BarChartRodData(toY: 12, color: Colors.indigo)]),
      BarChartGroupData(
          x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.deepPurple)]),
      BarChartGroupData(
          x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.pink)]),
      BarChartGroupData(
          x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.amber[800])]),
    ];

    final List<String> statusLabels = [
      'Delivered',
      'In Transit',
      'Pending',
      'Returned',
    ];

    String greeting = _getGreeting();

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: _currentThemeColor, // Use dynamic color
            title: Row(
              children: [
                Image.asset("assets/post_icon.png", height: 40),
                const SizedBox(width: 10),
                Text(
                  'Admin',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.displayName ?? "Admin User"),
              accountEmail: Text(currentUser?.email ?? "admin@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? _currentThemeColor
                        : Colors.white,
                child: currentUser?.profilePictureUrl != null &&
                        currentUser!.profilePictureUrl!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: currentUser.profilePictureUrl!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Text('A', style: TextStyle(fontSize: 40.0)),
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      )
                    : Text(
                        currentUser?.displayName?.isNotEmpty == true
                            ? currentUser!.displayName![0].toUpperCase()
                            : "A",
                        style: const TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(color: _currentThemeColor),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log Out'),
              onTap: () async {
                Navigator.pop(context);
                Provider.of<UserProvider>(context, listen: false).clearUser();
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
            const SizedBox(height: 16),
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'SansSerif',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: _currentHeaderBg, // Use dynamic header bg
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _currentThemeColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 48, color: _currentHeaderIcon),
                  const SizedBox(width: 18),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 18,
                          color: _currentHeaderIcon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.displayName ?? 'Admin User',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminActions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                return _buildAdminActionCard(
                  context,
                  adminActions[index]['title'] as String,
                  adminActions[index]['icon'] as IconData,
                );
              },
            ),
            const SizedBox(height: 20),
            // --- Beautiful Chart Section ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Parcels by Status",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 28),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final idx = value.toInt();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      idx >= 0 && idx < statusLabels.length
                                          ? statusLabels[idx]
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData:
                              FlGridData(show: true, horizontalInterval: 5),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour == 12) {
      return 'Good Afternoon';
    } else if (hour < 18) {
      return 'Good Evening';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildAdminActionCard(
      BuildContext context, String title, IconData icon) {
    Widget? screenToNavigate;
    Color cardColor = Colors.indigo.shade50;
    Color iconColor = Colors.indigo;
    // Assign color based on title
    switch (title) {
      case 'Manage Users':
        screenToNavigate = const ManageUsersScreen();
        iconColor = Colors.indigo;
        cardColor = Colors.indigo.shade100;
        break;
      case 'Manage Services':
        screenToNavigate = const ManageServicesScreen();
        iconColor = Colors.deepPurple;
        cardColor = Colors.deepPurple.shade50;
        break;
      case 'System Settings':
        // screenToNavigate = const SystemSettingsScreen();
        // iconColor = Colors.teal;
        // cardColor = Colors.teal.shade50;
        break;
      case 'Manage News Carousel':
        screenToNavigate = const AdminNewsCarouselScreen();
        iconColor = Colors.pink;
        cardColor = Colors.pink.shade50;
        break;
      case 'Parcel Tracking Control':
        screenToNavigate = const AdminParcelTrackingControlScreen();
        iconColor = Colors.amber[800]!;
        cardColor = Colors.amber.shade50;
        break;
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          setState(() {
            _setThemeForAction(title);
          });
          await Future.delayed(const Duration(milliseconds: 100));
          if (screenToNavigate != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screenToNavigate!),
            );
            setState(() {
              _setThemeForAction(''); // Reset to default on return
            });
          }
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
//first comment
