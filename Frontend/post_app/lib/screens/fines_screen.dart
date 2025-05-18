import 'package:flutter/material.dart';

class FinesScreen extends StatefulWidget {
  const FinesScreen({super.key});

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  String? _selectedType;
  final TextEditingController _amountController = TextEditingController();

  final List<String> _typeofFines = [
    'Driving without a license',
    'Employing a driver without a licence',
    'Driving under the influence of liquor / narcotics',
    'Transporting passengers for hire while being under the influence of liquor',
    'Causing injuries / death to a person while driving under the influence of liquor',
    'In case of causing serious injuries to a person',
    'In case of causing minor injuries to a person',
    'Driving through railway crossings in a haphazard manner',
    'Driving without a valid insurance cover',
    'Speeding',
    'Driving 20 percent more than the maximum speed limit',
    'Driving between 20 percent to 30 percent more the maximum speed limit',
    'Driving between 30 percent to 50 percent more the maximum speed limit',
    'Driving more than 50 percent of the maximum speed limit',
    'Overtaking from the left side / breaching road rules',
    'Other',
  ];

  final Map<String, String> _fineDetails = {
    'Driving without a license': 'First occasion - Rs 25,000\nSecond occasion - Rs 30,000',
    'Employing a driver without a licence': 'First occasion - Rs 25,000 - Rs 30,000\nSecond occasion - Rs 30,000 - Rs 50,000',
    'Driving under the influence of liquor / narcotics': 'Rs 25,000 - Rs 30,000 or\nImprisonment ≤ 3 months\nLicense suspension ≤ 1 year',
    'Transporting passengers for hire while being under the influence of liquor': 'Rs 25,000 - Rs 30,000\nImprisonment up to 6 months\nLicense cancellation',
    'Causing injuries / death to a person while driving under the influence of liquor': 'In case of death:\nRs 100,000 - Rs 150,000\nImprisonment 2–10 years\nLicense cancellation',
    'In case of causing serious injuries to a person': 'Rs 50,000 - Rs 100,000\nImprisonment ≤ 5 years\nLicense cancellation',
    'In case of causing minor injuries to a person': 'Rs 30,000 - Rs 50,000\nImprisonment ≤ 1 year\nLicense cancellation',
    'Driving through railway crossings in a haphazard manner': '1st: Rs 25,000 - Rs 30,000\n2nd: Rs 25,000 - Rs 40,000\n3rd: Rs 40,000 - Rs 50,000\nLicense suspension ≤ 12 months',
    'Driving without a valid insurance cover': 'Rs 25,000 - Rs 50,000\nImprisonment ≤ 1 month',
    'Speeding': 'Rs 1000 - Rs 2000\nRs 2000 - Rs 3000\nRs 3500 - Rs 5000',
    'Driving 20 percent more than the maximum speed limit': 'Rs 3000 - Rs 5000\nSpot fine: Rs 3000',
    'Driving between 20 percent to 30 percent more the maximum speed limit': 'Rs 5000 - Rs 10,000\nSpot fine: Rs 5000',
    'Driving between 30 percent to 50 percent more the maximum speed limit': 'Rs 10,000 - Rs 15,000\nSpot fine: Rs 10,000',
    'Driving more than 50 percent of the maximum speed limit': 'Rs 15,000 - Rs 25,000\nSpot fine: Rs 15,000',
    'Overtaking from the left side / breaching road rules': 'Rs 2500 - Rs 3500\nRs 3500 - Rs 5000\nRs 5000 - Rs 25,000\nSpot fine: Rs 2000',
    'Other': 'Please contact the nearest police station for more information.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Motor Traffic Fine'),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Select Type of Fine',
                    labelStyle: const TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pinkAccent),
                    ),
                  ),
                  items: _typeofFines.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedType != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _fineDetails[_selectedType!] ?? 'No details available',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount (LKR)',
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixText: 'LKR ',
                    prefixStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pinkAccent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.yellow;
                    }
                    return Colors.grey.shade300;
                  },
                ),
                foregroundColor: WidgetStateProperty.all(Colors.black),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16.0),
                ),
                elevation: WidgetStateProperty.all(4),
              ),
              onPressed: () {
                // Handle payment logic here
              },
              child: const Text(
                'Pay Fine',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
