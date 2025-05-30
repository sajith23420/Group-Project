import 'package:flutter/material.dart';

class KandyPostOfficeDetails extends StatelessWidget {
  const KandyPostOfficeDetails({super.key});

  final Map<String, dynamic> kandyPostOffice = const {
    'name': 'Kandy General Post Office',
    'address': 'No. 1, Post Office Lane, Kandy 20000',
    'phone': '+94 81 2 222222',
    'hours': '8:00 AM - 6:00 PM',
    'services': [
      'Postal services',
      'Parcel services',
      'Money orders',
      'Registered mail',
      'Express mail',
      'Philately',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kandy Post Office'),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F6FB),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_post_office, color: Colors.deepPurple, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      kandyPostOffice['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 44, 20, 80),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kandyPostOffice['address'],
                        style: const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      kandyPostOffice['phone'],
                      style: const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      kandyPostOffice['hours'],
                      style: const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Services:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  kandyPostOffice['services'].length,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          kandyPostOffice['services'][i],
                          style: const TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
