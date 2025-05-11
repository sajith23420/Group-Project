import 'package:flutter/material.dart';

class ParcelTrackingScreen extends StatelessWidget {
  const ParcelTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcel Tracking'),
      ),
      body: const Center(
        child: Text('Parcel Tracking Screen Content'),
      ),
    );
  }
}
