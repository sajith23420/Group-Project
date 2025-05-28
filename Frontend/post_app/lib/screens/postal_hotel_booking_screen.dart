import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostalHotelBookingScreen extends StatelessWidget {
  const PostalHotelBookingScreen({Key? key}) : super(key: key);

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
            title: const Text('Postal Hotel Booking'),
            backgroundColor: Colors.blue, // Changed to blue
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.hotel,
                  size: 80, color: Colors.blue), // Changed to blue
              const SizedBox(height: 24),
              const Text(
                'Book your stay at our postal hotels!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Find and book postal hotels conveniently through this page. More features coming soon!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_business, color: Colors.white),
                label: const Text('Start Booking',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Changed to blue
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final url = Uri.parse('https://www.booking.com/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not open booking.com')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
