import 'package:flutter/material.dart';

// Import admin action screens
import 'package:post_app/screens/admin/manage_users_screen.dart';
import 'package:post_app/screens/admin/view_reports_screen.dart';
import 'package:post_app/screens/admin/manage_services_screen.dart';
import 'package:post_app/screens/admin/manage_content_screen.dart';
import 'package:post_app/screens/admin/system_settings_screen.dart';
import 'package:post_app/screens/admin/view_logs_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminActions = [
      {'title': 'Manage Users', 'icon': Icons.people_outline},
      {'title': 'View Reports', 'icon': Icons.analytics_outlined},
      {'title': 'Manage Services', 'icon': Icons.settings_applications_outlined},
      {'title': 'Manage Content', 'icon': Icons.article_outlined},
      {'title': 'System Settings', 'icon': Icons.settings_outlined},
      {'title': 'View Logs', 'icon': Icons.list_alt_outlined},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false, // Admins might not need a back button here
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

  Widget _buildAdminActionCard(BuildContext context, String title, IconData icon) {
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
