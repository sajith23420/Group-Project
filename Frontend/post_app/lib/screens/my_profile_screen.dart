import 'package:flutter/material.dart';
import 'package:post_app/screens/edit_profile_screen.dart'; // Added import
import 'package:post_app/screens/change_password_screen.dart'; // Added import
import 'package:post_app/screens/contact_details_screen.dart'; // Added import
import 'package:post_app/screens/help_support_screen.dart'; // Added import
import 'package:post_app/screens/notification_settings_screen.dart'; // Added import
import 'package:post_app/screens/login_screen.dart'; // Import LoginScreen

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        // If this screen is part of the MainAppShell, the AppBar might be handled there.
        // For a standalone page accessed from drawer, this AppBar is fine.
        // If it's part of MainAppShell, MainAppShell's Scaffold would have the AppBar.
        // The current MainAppShell does not give individual AppBars to its pages,
        // so this AppBar will be shown.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: null, // Placeholder for an image
              child: Icon(Icons.person, size: 50), // Fallback icon
            ),
            const SizedBox(height: 16),
            const Text(
              'User Name', // Placeholder
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'user.email@example.com', // Placeholder
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildProfileOption(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push( // Added navigation
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push( // Added navigation
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              onTap: () {
                Navigator.push( // Added navigation
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Show Privacy Policy
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                 Navigator.push( // Added navigation
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                );
              },
            ),
            _buildProfileOption( // Added Contact Details option
              context,
              icon: Icons.contact_phone_outlined,
              title: 'Contact Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                // TODO: Implement actual logout logic (e.g., clear tokens, user data)

                // Navigate to LoginScreen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
