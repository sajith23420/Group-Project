import 'package:flutter/material.dart';

class FeedbacksPage extends StatelessWidget {
  const FeedbacksPage({super.key});

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
