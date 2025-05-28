import 'package:flutter/material.dart';

class PostalHolidayScreen extends StatelessWidget {
  const PostalHolidayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postal Holiday'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Postal Holiday Page',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
