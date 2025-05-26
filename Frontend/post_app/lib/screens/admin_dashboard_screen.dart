import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:post_app/providers/user_provider.dart'; // Import UserProvider
import 'package:post_app/models/user_model.dart'; // Import UserModel
import 'package:post_app/screens/login_screen.dart'; // Import LoginScreen
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage

// Import admin action screens
import 'package:post_app/screens/admin/manage_users_screen.dart';
import 'package:post_app/screens/admin/view_reports_screen.dart';
import 'package:post_app/screens/admin/manage_services_screen.dart';
import 'package:post_app/screens/admin/manage_content_screen.dart';
import 'package:post_app/screens/admin/system_settings_screen.dart';
import 'package:post_app/screens/admin/view_logs_screen.dart';
import 'package:post_app/screens/admin/admin_news_carousel_screen.dart';
import 'package:post_app/screens/admin/admin_parcel_tracking_control_screen.dart'; // Import the new screen

class AdminDashboardScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Added State class
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // For opening drawer

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? currentUser = userProvider.user;

    final List<Map<String, dynamic>> adminActions = [
      {'title': 'Manage Users', 'icon': Icons.people_outline},
      {'title': 'View Reports', 'icon': Icons.analytics_outlined},
      {
        'title': 'Manage Services',
        'icon': Icons.settings_applications_outlined
      },
      {'title': 'Manage Content', 'icon': Icons.article_outlined},
      {'title': 'System Settings', 'icon': Icons.settings_outlined},
      {'title': 'View Logs', 'icon': Icons.list_alt_outlined},
      {'title': 'Manage News Carousel', 'icon': Icons.newspaper},
      {
        'title': 'Parcel Tracking Control',
        'icon': Icons.local_shipping_outlined
      }, // Add this line for the new admin action
    ];

    return Scaffold(
      key: _scaffoldKey, // Assign key to Scaffold
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          // Added actions for the drawer icon
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // Open drawer
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        // Added endDrawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.displayName ?? "Admin User"),
              accountEmail: Text(currentUser?.email ?? "admin@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: currentUser?.profilePictureUrl != null &&
                        currentUser!.profilePictureUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(currentUser
                        .profilePictureUrl!) // Use CachedNetworkImageProvider
                    : null,
                child: currentUser?.profilePictureUrl == null ||
                        currentUser!.profilePictureUrl!.isEmpty
                    ? Text(
                        currentUser?.displayName?.isNotEmpty == true
                            ? currentUser!.displayName![0].toUpperCase()
                            : "A",
                        style: const TextStyle(fontSize: 40.0))
                    : null,
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            // Optional: Add other admin-specific drawer items here if needed
            // ListTile(
            //   leading: const Icon(Icons.settings_applications_outlined),
            //   title: const Text('Admin Settings'), // Example
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Navigate to an admin settings screen
            //   },
            // ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log Out'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
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
            const Text(
              'Admin Actions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminActions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row for admin actions
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.2, // Adjust aspect ratio
              ),
              itemBuilder: (context, index) {
                return _buildAdminActionCard(
                  context,
                  adminActions[index]['title'] as String,
                  adminActions[index]['icon'] as IconData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionCard(
      BuildContext context, String title, IconData icon) {
    Widget? screenToNavigate;

    switch (title) {
      case 'Manage Users':
        screenToNavigate = const ManageUsersScreen();
        break;
      case 'View Reports':
        screenToNavigate = const ViewReportsScreen();
        break;
      case 'Manage Services':
        screenToNavigate = const ManageServicesScreen();
        break;
      case 'Manage Content':
        screenToNavigate = const ManageContentScreen();
        break;
      case 'System Settings':
        screenToNavigate = const SystemSettingsScreen();
        break;
      case 'View Logs':
        screenToNavigate = const ViewLogsScreen();
        break;
      case 'Manage News Carousel':
        screenToNavigate = const AdminNewsCarouselScreen();
        break;
      case 'Parcel Tracking Control':
        screenToNavigate = const AdminParcelTrackingControlScreen();
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          if (screenToNavigate != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screenToNavigate!),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
//first comment
