import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:path/path.dart';
import 'package:post_app/screens/main_app_shell.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (Context) {
                return MainAppShell();
              }));
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset('post.jpg')),
            SizedBox(
              height: 30,
            ),
            Center(
              child: const Text(
                'About Sri Lanka Post App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(45, 158, 158, 158),
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Version 1.0.0', // Sample version
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'This is a sample mobile application for SL Post, providing various services to customers.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Key features include parcel tracking, money order services, bill payments, postal holiday information, searching for nearby post offices, fines information, and stamp collection details.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Developed with Flutter.',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200,
                height: 48,
                child: OutlinedButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.googlePlay,
                    color: Colors.pinkAccent,
                  ),
                  label: Text("Rate Our App"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1.5, color: Colors.pinkAccent),
                  ),
                  onPressed: () async {
                    //Forward to playstore homepage,after implementing app,can redirect to postSApp
                    final Uri playStoreUri =
                        Uri.parse('https://play.google.com/store');
                    if (await canLaunchUrl(playStoreUri)) {
                      await launchUrl(playStoreUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not Open play Store';
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton.icon(
                    icon: Icon(color: Colors.white, Icons.home),
                    label: Text("Back to Home"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MainAppShell();
                      }));
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
