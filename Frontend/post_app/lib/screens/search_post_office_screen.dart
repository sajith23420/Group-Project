import 'package:flutter/material.dart';

class SearchPostOfficeScreen extends StatelessWidget {
  const SearchPostOfficeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Nearby Post Office'),
      ),
      body: const Center(
        child: Text('Search Nearby Post Office Screen Content'),
      ),
    );
  }
}
