import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _parcelUpdates = true;
  bool _promotions = false;
  bool _serviceAnnouncements = true;

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Notification Settings',
                style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Manage your notification preferences.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24.0),
            SwitchListTile(
              title: const Text('Parcel Updates'),
              subtitle: const Text(
                  'Receive notifications about your parcel status changes.'),
              value: _parcelUpdates,
              onChanged: (bool value) {
                setState(() {
                  _parcelUpdates = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Promotions and Offers'),
              subtitle: const Text(
                  'Receive marketing communications and special offers.'),
              value: _promotions,
              onChanged: (bool value) {
                setState(() {
                  _promotions = value;
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Service Announcements'),
              subtitle: const Text(
                  'Receive important updates about SL Post services.'),
              value: _serviceAnnouncements,
              onChanged: (bool value) {
                setState(() {
                  _serviceAnnouncements = value;
                });
              },
            ),
            const Divider(),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // TODO: Save notification settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved (placeholder)')),
                );
              },
              child: const Text('Save Settings',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
