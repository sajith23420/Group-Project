import 'package:flutter/material.dart';


class AddPaymentCardScreen extends StatelessWidget {
  const AddPaymentCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey for the Form (optional for just UI)
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                // validator: (value) { ... } // Add validation later if needed
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                      // validator: (value) { ... } // Add validation later if needed
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      // validator: (value) { ... } // Add validation later if needed
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                // validator: (value) { ... } // Add validation later if needed
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // if (_formKey.currentState!.validate()) {
                  //   // Save card details
                  // }
                },
                child: const Text('Save Card', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
