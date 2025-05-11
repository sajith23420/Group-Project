import 'package:flutter/material.dart';

class MoneyOrderScreen extends StatelessWidget {
  const MoneyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Order'),
      ),
      body: const Center(
        child: Text('Money Order Screen Content'),
      ),
    );
  }
}
