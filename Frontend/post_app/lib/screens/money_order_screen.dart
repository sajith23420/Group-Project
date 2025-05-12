import 'package:flutter/material.dart';

class MoneyOrderScreen extends StatelessWidget {
  const MoneyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey for the Form
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Sender Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Sender's Full Name",
                  border: OutlineInputBorder(),
                ),
                // validator: (value) { ... } // Add validation later if needed
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Sender's Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Recipient Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Recipient's Full Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Recipient's Address",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount (LKR)',
                  border: OutlineInputBorder(),
                  prefixText: 'LKR ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // if (_formKey.currentState!.validate()) {
                  //   // Process data
                  // }
                },
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
