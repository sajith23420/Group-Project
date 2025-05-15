import 'package:flutter/material.dart';

class ParcelTrackingScreen extends StatelessWidget {
  const ParcelTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GlobalKey for the Form (optional for just UI, but good practice)
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcel Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter Tracking Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tracking Number',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
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
                  //   // Trigger tracking logic
                  // }
                },
                child: const Text('Track Parcel', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 30.0),
              const Text(
                'Tracking Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              // Placeholder for tracking results
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    'Tracking information will appear here after searching.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
