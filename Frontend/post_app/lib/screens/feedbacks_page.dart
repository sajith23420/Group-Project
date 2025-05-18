import 'package:flutter/material.dart';

class FeedbacksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks'),
      ),
      body: const Center(
        child: Text('Feedbacks will be shown here.'),
      ),
    );
  }
}
